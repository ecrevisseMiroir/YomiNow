import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/dictionary_entry.dart';
import 'dictionary_service.dart';

const _assetKey = 'assets/dict/jmdict.db.gz';
const _versionKey = 'assets/dict/jmdict.version';

/// Entries of one term, best first: common forms, then by entry id.
const _lookupSql = '''
SELECT e.id, e.json
FROM (SELECT entry_id, MAX(priority) AS priority
      FROM terms WHERE term = ? GROUP BY entry_id) AS t
JOIN entries e ON e.id = t.entry_id
ORDER BY t.priority DESC, e.id
LIMIT ?
''';

/// [DictionaryService] backed by the JMdict SQLite database built by
/// `tool/build_jmdict.dart`.
class SqliteDictionaryService implements DictionaryService {
  /// Uses the database at [databasePath] when given. By default the bundled
  /// `assets/dict/jmdict.db.gz` (read from [bundle], `rootBundle` unless
  /// given) is extracted to the application support directory, again whenever
  /// its `jmdict.version` file changes.
  SqliteDictionaryService({
    Future<String> Function()? databasePath,
    AssetBundle? bundle,
  }) : _databasePath =
           databasePath ??
           (() => _extractBundledDatabase(bundle ?? rootBundle));

  final Future<String> Function() _databasePath;
  Database? _db;
  Future<void>? _opening;

  @override
  Future<void> open() => _opening ??= _openDatabase();

  Future<void> _openDatabase() async {
    try {
      _db = sqlite3.open(await _databasePath(), mode: OpenMode.readOnly);
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  @override
  Future<List<DictionaryEntry>> lookup(String term, {int limit = 10}) async {
    await open();
    return _entries(_db!.select(_lookupSql, [term, limit]));
  }

  @override
  Future<DictionaryMatch?> longestMatch(
    String text,
    int from, {
    int maxLength = 12,
  }) async {
    if (from < 0 || from >= text.length) return null;

    final prefixes = <String>[];
    final prefix = StringBuffer();
    for (final rune in text.substring(from).runes.take(maxLength)) {
      prefix.writeCharCode(rune);
      prefixes.add(prefix.toString());
    }
    if (prefixes.isEmpty) return null;

    // All prefixes are prefixes of one string, so the longest hit is the one
    // with the most characters.
    await open();
    final rows = _db!.select('''
      WITH hits AS (
        SELECT term, entry_id, MAX(priority) AS priority
        FROM terms WHERE term IN (${List.filled(prefixes.length, '?').join(',')})
        GROUP BY term, entry_id
      )
      SELECT h.term, e.id, e.json
      FROM hits h
      JOIN entries e ON e.id = h.entry_id
      WHERE LENGTH(h.term) = (SELECT MAX(LENGTH(term)) FROM hits)
      ORDER BY h.priority DESC, e.id
      ''', prefixes);
    if (rows.isEmpty) return null;
    return DictionaryMatch(
      term: rows.first['term'] as String,
      entries: _entries(rows),
    );
  }

  @override
  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await opening.catchError((Object _) {});
    _db?.close();
    _db = null;
  }
}

/// Decodes the `id` and `json` columns of [rows].
List<DictionaryEntry> _entries(ResultSet rows) => [
  for (final row in rows)
    DictionaryEntry.fromJson(
      row['id'] as int,
      jsonDecode(row['json'] as String) as Map<String, dynamic>,
    ),
];

/// Extracts the bundled database to
/// `<application support>/dict/jmdict.db` and returns its path.
///
/// The small `jmdict.version` asset identifies the bundled database. It is
/// stored next to the extracted file as a marker once extraction succeeded,
/// so as long as the two match, the large `.gz` asset is not even loaded.
Future<String> _extractBundledDatabase(AssetBundle bundle) async {
  final version = (await bundle.loadString(_versionKey, cache: false)).trim();

  final support = await getApplicationSupportDirectory();
  final database = File(p.join(support.path, 'dict', 'jmdict.db'));
  final marker = File('${database.path}.version');
  if (await database.exists() &&
      await marker.exists() &&
      await marker.readAsString() == version) {
    return database.path;
  }

  final asset = await bundle.load(_assetKey);
  final gz = asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);

  // Extract beside the target and rename, so an interrupted run never leaves
  // a truncated database that the marker vouches for.
  await database.parent.create(recursive: true);
  final partial = '${database.path}.partial';
  await _gunzipInBackground(gz, partial);
  await File(partial).rename(database.path);
  await marker.writeAsString(version);
  return database.path;
}

Future<void> _gunzipInBackground(Uint8List gz, String path) => Isolate.run(
  () => gzip.decoder.bind(Stream.value(gz)).pipe(File(path).openWrite()),
);
