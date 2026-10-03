/// Builds the bundled dictionary database (`assets/dict/jmdict.db.gz`) from
/// JMdict, either the official `JMdict_e` XML or a jamdict-data SQLite file.
///
/// The output schema is what `SqliteDictionaryService` reads:
///
/// ```sql
/// CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT NOT NULL);
/// CREATE TABLE entries(id INTEGER PRIMARY KEY, json TEXT NOT NULL);
/// CREATE TABLE terms(term TEXT NOT NULL, entry_id INTEGER NOT NULL,
///                    priority INTEGER NOT NULL);
/// CREATE INDEX terms_term ON terms(term);
/// ```
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:yominow/models/dictionary_entry.dart';

const _license =
    'JMdict © Electronic Dictionary Research and Development Group, '
    'CC BY-SA 4.0';

/// Priority tags that make a form "common".
const _commonTags = {'news1', 'ichi1', 'spec1', 'spec2', 'gai1'};

/// Row counts and file sizes of a finished build.
class BuildStats {
  const BuildStats({
    required this.entries,
    required this.terms,
    required this.dbBytes,
    required this.gzBytes,
    required this.fingerprint,
  });

  /// Rows written to `entries`.
  final int entries;

  /// Rows written to `terms`.
  final int terms;

  /// Size of the uncompressed database file.
  final int dbBytes;

  /// Size of the gzipped database file.
  final int gzBytes;

  /// The gzip's fingerprint, as written to its version file.
  final String fingerprint;
}

/// The version file that belongs to the gzipped database at [gzPath]: same
/// directory, `.version` instead of `.db.gz` (`jmdict.db.gz` becomes
/// `jmdict.version`).
String versionPathFor(String gzPath) =>
    '${gzPath.replaceFirst(RegExp(r'(\.db)?\.gz$'), '')}.version';

/// Writes the version file for the gzip at [gzPath] and returns its content:
/// the file's SHA-256 in hex and its length in bytes, on one line.
///
/// The app compares this line with the one stored when it last extracted the
/// database, so it can tell whether the bundled asset changed without loading
/// the asset itself.
Future<String> writeVersionFile(String gzPath) async {
  final bytes = await File(gzPath).readAsBytes();
  final fingerprint = '${sha256.convert(bytes)} ${bytes.length}';
  await File(versionPathFor(gzPath))
      .writeAsBytes(utf8.encode('$fingerprint\n'));

  return fingerprint;
}

/// Builds the database from the official `JMdict_e` XML file (plain or
/// `.gz`), writing the raw SQLite file to [dbPath] and its gzip to [gzPath],
/// with the gzip's version file next to it (see [writeVersionFile]).
///
/// The XML is stream-parsed one `<entry>` at a time. Entities declared in the
/// file's DOCTYPE (`<!ENTITY n "noun (common) (futsuumeishi)">`) are expanded
/// in `pos`, `misc`, `field` and `dial`; the latter two are stored as further
/// `misc` labels of the sense (`field`, `misc`, `dial` order). Only English
/// glosses are kept. With [commonOnly], entries without a common form are
/// left out.
Future<BuildStats> buildFromJmdictXml(
  String xmlPath, {
  required String dbPath,
  required String gzPath,
  bool commonOnly = false,
}) => _build(
  dbPath: dbPath,
  gzPath: gzPath,
  commonOnly: commonOnly,
  source: 'JMdict_e',
  read: (add) => _readJmdictXml(xmlPath, add),
);

/// Builds the database from a jamdict-data SQLite file, writing the raw
/// SQLite file to [dbPath], its gzip to [gzPath] and the gzip's version file
/// next to it. The output is the same as [buildFromJmdictXml] would produce
/// from the same JMdict release.
Future<BuildStats> buildFromJamdict(
  String jamdictPath, {
  required String dbPath,
  required String gzPath,
  bool commonOnly = false,
}) => _build(
  dbPath: dbPath,
  gzPath: gzPath,
  commonOnly: commonOnly,
  source: 'jamdict-data',
  read: (add) => _readJamdict(jamdictPath, add),
);

Future<BuildStats> _build({
  required String dbPath,
  required String gzPath,
  required bool commonOnly,
  required String source,
  required FutureOr<String> Function(void Function(_Record) add) read,
}) async {
  final writer = _DatabaseWriter(dbPath, commonOnly: commonOnly);
  try {
    final sourceDate = await read(writer.add);
    writer.finish(source: source, sourceDate: sourceDate);
  } finally {
    writer.close();
  }
  await File(gzPath).parent.create(recursive: true);
  await File(dbPath)
      .openRead()
      .transform(GZipCodec(level: ZLibOption.maxLevel).encoder)
      .pipe(File(gzPath).openWrite());
  return BuildStats(
    entries: writer.entries,
    terms: writer.terms,
    dbBytes: File(dbPath).lengthSync(),
    gzBytes: File(gzPath).lengthSync(),
    fingerprint: await writeVersionFile(gzPath),
  );
}

/// One kanji form or reading and whether it carries a common priority tag.
typedef _Form = ({String text, bool common});

/// An entry as read from a source, with the per-form priority that the
/// `terms` table needs and [DictionaryEntry] does not keep.
class _Record {
  _Record({
    required this.id,
    required this.kanji,
    required this.readings,
    required this.senses,
  });

  final int id;
  final List<_Form> kanji;
  final List<_Form> readings;
  final List<Sense> senses;

  bool get common => [...kanji, ...readings].any((form) => form.common);

  DictionaryEntry get entry => DictionaryEntry(
    id: id,
    kanji: [for (final form in kanji) form.text],
    readings: [for (final form in readings) form.text],
    senses: senses,
    common: common,
  );

  /// One priority (1 = common, else 0) per distinct form.
  Map<String, int> get termPriorities {
    final priorities = <String, int>{};
    for (final form in [...kanji, ...readings]) {
      priorities[form.text] = max(
        priorities[form.text] ?? 0,
        form.common ? 1 : 0,
      );
    }
    return priorities;
  }
}

/// JMdict omits `pos` on a sense that has the same parts of speech as the
/// one before it. Fills those in, and drops senses without English glosses.
List<Sense> _resolveSenses(List<Sense> senses) {
  final resolved = <Sense>[];
  var pos = const <String>[];
  for (final sense in senses) {
    if (sense.pos.isNotEmpty) pos = sense.pos;
    if (sense.glosses.isEmpty) continue;
    resolved.add(Sense(pos: pos, glosses: sense.glosses, misc: sense.misc));
  }
  return resolved;
}

/// Writes records into the output schema inside a single transaction.
class _DatabaseWriter {
  _DatabaseWriter(String path, {required this.commonOnly})
    : _db = _createDatabase(path) {
    _db.execute('''
      PRAGMA journal_mode = OFF;
      PRAGMA synchronous = OFF;
      CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT NOT NULL);
      CREATE TABLE entries(id INTEGER PRIMARY KEY, json TEXT NOT NULL);
      CREATE TABLE terms(term TEXT NOT NULL, entry_id INTEGER NOT NULL, priority INTEGER NOT NULL);
      BEGIN;
    ''');
    _insertEntry = _db.prepare('INSERT INTO entries VALUES (?, ?)');
    _insertTerm = _db.prepare('INSERT INTO terms VALUES (?, ?, ?)');
  }

  final bool commonOnly;
  final Database _db;
  late final PreparedStatement _insertEntry;
  late final PreparedStatement _insertTerm;

  int entries = 0;
  int terms = 0;

  static Database _createDatabase(String path) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    if (file.existsSync()) file.deleteSync();
    return sqlite3.open(path);
  }

  void add(_Record record) {
    if (record.senses.isEmpty || (commonOnly && !record.common)) return;
    _insertEntry.execute([record.id, jsonEncode(record.entry.toJson())]);
    entries++;
    for (final MapEntry(key: term, value: priority)
        in record.termPriorities.entries) {
      _insertTerm.execute([term, record.id, priority]);
      terms++;
    }
  }

  /// Commits, indexes, writes `meta` and compacts the file.
  void finish({required String source, required String sourceDate}) {
    _insertEntry.close();
    _insertTerm.close();
    _db.execute('COMMIT');
    _db.execute('CREATE INDEX terms_term ON terms(term)');
    final meta = {
      'source': source,
      'source_date': sourceDate,
      'built_at': DateTime.now().toUtc().toIso8601String(),
      'license': _license,
    };
    for (final MapEntry(:key, :value) in meta.entries) {
      _db.execute('INSERT INTO meta VALUES (?, ?)', [key, value]);
    }
    _db.execute('VACUUM');
  }

  void close() => _db.close();
}

// ---------------------------------------------------------------------------
// JMdict XML

final _entityDeclaration = RegExp(r'<!ENTITY\s+(\S+)\s+"([^"]*)"\s*>');
final _dtdComment = RegExp(r'<!--.*?-->', dotAll: true);
final _createdComment = RegExp(r'JMdict created: (\d{4}-\d{2}-\d{2})');

/// Streams [path] and reports each `<entry>` to [add]. Returns the file's
/// creation date, or `unknown` when it has none.
Future<String> _readJmdictXml(String path, void Function(_Record) add) async {
  var bytes = File(path).openRead();
  if (path.endsWith('.gz')) bytes = bytes.transform(gzip.decoder);
  final events = bytes
      .transform(utf8.decoder)
      .toXmlEvents()
      .normalizeEvents()
      .flatten();

  var entities = const <String, String>{};
  var date = 'unknown';
  List<XmlEvent>? entryEvents;
  await for (final event in events) {
    if (entryEvents != null) {
      entryEvents.add(event);
      if (event is XmlEndElementEvent && event.name == 'entry') {
        final entry = const XmlNodeDecoder().convert(entryEvents).single;
        add(_parseEntry(entry as XmlElement, entities));
        entryEvents = null;
      }
    } else if (event is XmlStartElementEvent && event.name == 'entry') {
      entryEvents = [event];
    } else if (event is XmlDoctypeEvent) {
      entities = _parseEntities(event.internalSubset ?? '');
    } else if (event is XmlCommentEvent) {
      date = _createdComment.firstMatch(event.value)?.group(1) ?? date;
    }
  }
  return date;
}

/// Entity name to expansion, from the `<!ENTITY>` declarations in a DTD.
Map<String, String> _parseEntities(String internalSubset) => {
  for (final match in _entityDeclaration.allMatches(
    internalSubset.replaceAll(_dtdComment, ''),
  ))
    match[1]!: match[2]!,
};

/// `&n;` becomes the text declared for `n`; other text is returned as is.
/// (The XML parser leaves entities it does not know untouched.)
String _expandEntity(String text, Map<String, String> entities) {
  if (!text.startsWith('&') || !text.endsWith(';')) return text;
  return entities[text.substring(1, text.length - 1)] ??
      (throw FormatException('Undeclared entity $text'));
}

bool _isEnglish(XmlElement gloss) =>
    (gloss.getAttribute('xml:lang') ?? 'eng') == 'eng';

_Record _parseEntry(XmlElement entry, Map<String, String> entities) {
  List<_Form> forms(String element, String text, String priority) => [
    for (final form in entry.findElements(element))
      (
        text: form.getElement(text)!.innerText,
        common: form
            .findElements(priority)
            .any((tag) => _commonTags.contains(tag.innerText)),
      ),
  ];

  String label(XmlElement element) =>
      _expandEntity(element.innerText, entities);

  return _Record(
    id: int.parse(entry.getElement('ent_seq')!.innerText),
    kanji: forms('k_ele', 'keb', 'ke_pri'),
    readings: forms('r_ele', 'reb', 're_pri'),
    senses: _resolveSenses([
      for (final sense in entry.findElements('sense'))
        Sense(
          pos: [for (final e in sense.findElements('pos')) label(e)],
          glosses: [
            for (final gloss in sense.findElements('gloss'))
              if (_isEnglish(gloss)) gloss.innerText,
          ],
          misc: [
            for (final tag in const ['field', 'misc', 'dial'])
              for (final e in sense.findElements(tag)) label(e),
          ],
        ),
    ]),
  );
}

// ---------------------------------------------------------------------------
// jamdict-data SQLite

/// Groups the rows of [rows] by their first column (an integer key).
Map<int, List<T>> _groupByKey<T>(ResultSet rows, T Function(Row row) value) {
  final groups = <int, List<T>>{};
  for (final row in rows) {
    (groups[row.columnAt(0) as int] ??= []).add(value(row));
  }
  return groups;
}

/// Reads every entry of the jamdict database at [path] and reports it to
/// [add]. Returns the source date.
///
/// jamdict-data does not record when its JMdict was generated. It ships
/// JMdict and JMnedict together, so the JMnedict date is used as the closest
/// available approximation.
String _readJamdict(String path, void Function(_Record) add) {
  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    String text(Row row) => row.columnAt(1) as String;
    Map<int, List<String>> bySense(String sql) =>
        _groupByKey(db.select(sql), text);
    Map<int, List<_Form>> forms(String table, String tagTable) {
      final tags = _groupByKey(
        db.select('SELECT kid, text FROM $tagTable'),
        text,
      );
      return _groupByKey(
        db.select('SELECT idseq, ID, text FROM $table ORDER BY ID'),
        (row) => (
          text: row.columnAt(2) as String,
          common: (tags[row.columnAt(1) as int] ?? const []).any(
            _commonTags.contains,
          ),
        ),
      );
    }

    final kanji = forms('Kanji', 'KJP');
    final readings = forms('Kana', 'KNP');
    final senseIds = _groupByKey(
      db.select('SELECT idseq, ID FROM Sense ORDER BY ID'),
      (row) => row.columnAt(1) as int,
    );
    final pos = bySense('SELECT sid, text FROM pos ORDER BY rowid');
    final field = bySense('SELECT sid, text FROM field ORDER BY rowid');
    final misc = bySense('SELECT sid, text FROM misc ORDER BY rowid');
    final dialect = bySense('SELECT sid, text FROM dialect ORDER BY rowid');
    final glosses = bySense(
      "SELECT sid, text FROM SenseGloss WHERE lang = 'eng' ORDER BY rowid",
    );

    for (final row in db.select('SELECT idseq FROM Entry ORDER BY idseq')) {
      final id = row.columnAt(0) as int;
      add(
        _Record(
          id: id,
          kanji: kanji[id] ?? const [],
          readings: readings[id] ?? const [],
          senses: _resolveSenses([
            for (final sid in senseIds[id] ?? const <int>[])
              Sense(
                pos: pos[sid] ?? const [],
                glosses: glosses[sid] ?? const [],
                misc: [...?field[sid], ...?misc[sid], ...?dialect[sid]],
              ),
          ]),
        ),
      );
    }

    final date = db.select(
      "SELECT value FROM meta WHERE key = 'jmnedict.date'",
    );
    return date.isEmpty ? 'unknown' : date.first.columnAt(0) as String;
  } finally {
    db.close();
  }
}
