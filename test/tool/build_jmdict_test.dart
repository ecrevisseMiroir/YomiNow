import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:yominow/models/dictionary_entry.dart';

import '../../tool/src/jmdict_builder.dart';

const _fixture = 'test/fixtures/jmdict_sample.xml';

Map<String, dynamic> _jsonOf(String json) =>
    jsonDecode(json) as Map<String, dynamic>;

void main() {
  late Directory tmp;
  late String dbPath;
  late String gzPath;
  late BuildStats stats;
  late Database db;

  DictionaryEntry entry(int id) {
    final row = db.select('SELECT json FROM entries WHERE id = ?', [id]).single;
    return DictionaryEntry.fromJson(id, _jsonOf(row['json'] as String));
  }

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('build_jmdict_test');
    dbPath = p.join(tmp.path, 'jmdict.db');
    gzPath = p.join(tmp.path, 'jmdict.db.gz');
    stats = await buildFromJmdictXml(_fixture, dbPath: dbPath, gzPath: gzPath);
    db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
  });

  tearDownAll(() {
    db.close();
    tmp.deleteSync(recursive: true);
  });

  test('reports counts and sizes', () {
    expect(stats.entries, 8);
    expect(stats.terms, 22);
    expect(stats.dbBytes, File(dbPath).lengthSync());
    expect(stats.gzBytes, File(gzPath).lengthSync());
    expect(stats.gzBytes, lessThan(stats.dbBytes));
    expect(db.select('SELECT COUNT(*) FROM entries').single.columnAt(0), 8);
    expect(db.select('SELECT COUNT(*) FROM terms').single.columnAt(0), 22);
  });

  test('expands DOCTYPE entities in pos and misc', () {
    final iku = entry(1578850);
    expect(iku.senses.first.pos, [
      'Godan verb - Iku/Yuku special class',
      'intransitive verb',
    ]);
    expect(iku.senses.last.pos, [
      'Godan verb - Iku/Yuku special class',
      'auxiliary verb',
    ]);
    expect(iku.senses.last.misc, ['word usually written using kana alone']);
    expect(entry(1358280).senses.first.pos, [
      'Ichidan verb',
      'transitive verb',
    ]);
    expect(entry(1582710).senses.single.pos, ['noun (common) (futsuumeishi)']);
  });

  test('a sense without pos inherits the previous sense pos', () {
    final taberu = entry(1358280);
    expect(taberu.senses, hasLength(2));
    expect(taberu.senses[1].pos, taberu.senses[0].pos);
    expect(taberu.senses[1].glosses.first, 'to live on (e.g. a salary)');

    // A run of pos-less senses all take the pos of the last explicit one.
    final iku = entry(1578850);
    expect(iku.senses, hasLength(4));
    expect(iku.senses[1].pos, iku.senses[0].pos);
    expect(iku.senses[2].pos, iku.senses[0].pos);
    expect(iku.senses[3].pos, contains('auxiliary verb'));
    expect([
      for (final s in entry(1219950).senses) s.pos,
    ], everyElement(['noun (common) (futsuumeishi)', 'prefix']));
  });

  test('keeps only English glosses and decodes XML entities', () {
    expect(entry(1464530).senses.single.glosses, ['Japanese (language)']);
    expect(entry(1157500).senses.single.glosses, [
      'reverence',
      'awe',
      'fear & dread',
    ]);
  });

  test('stores kana-only entries compactly', () {
    final row = db.select('SELECT json FROM entries WHERE id = 2216120').single;
    expect(_jsonOf(row['json'] as String), {
      'r': ['これ'],
      's': [
        {
          'p': ['interjection (kandoushi)'],
          'g': ['hey', 'oi', 'come on'],
        },
      ],
    });
    final kore = entry(2216120);
    expect(kore.kanji, isEmpty);
    expect(kore.headword, 'これ');
  });

  test('flags entries with a news1/ichi1/spec1/spec2/gai1 form as common', () {
    final common = {
      for (final id in [
        1157500,
        1219950,
        1358280,
        1464530,
        1578850,
        1582710,
        1628530,
        2216120,
      ])
        id: entry(id).common,
    };
    expect(common, {
      1157500: false, // news2 and nf40 only
      1219950: true, // ichi1
      1358280: true, // ichi1
      1464530: true, // news1
      1578850: true, // ichi1
      1582710: true, // spec1
      1628530: true, // ichi1
      2216120: false, // no priority at all
    });
  });

  test('writes one term row per distinct form with its own priority', () {
    Map<String, int> termsOf(int id) => {
      for (final row in db.select(
        'SELECT term, priority FROM terms WHERE entry_id = ?',
        [id],
      ))
        row['term'] as String: row['priority'] as int,
    };

    expect(termsOf(1582710), {'日本': 1, 'にほん': 1, 'にっぽん': 0});
    expect(termsOf(1578850), {'行く': 1, '逝く': 0, '往く': 0, 'いく': 1, 'ゆく': 1});
    expect(termsOf(1358280), {'食べる': 1, '喰べる': 0, 'たべる': 1});
    expect(termsOf(2216120), {'これ': 0});
    expect(termsOf(1157500), {'畏懼': 0, 'いく': 0});
  });

  test('indexes terms', () {
    final indexes = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 'terms'",
    );
    expect(indexes.map((row) => row['name']), contains('terms_term'));
  });

  test('writes meta rows', () {
    final meta = {
      for (final row in db.select('SELECT key, value FROM meta'))
        row['key'] as String: row['value'] as String,
    };
    expect(meta.keys, {'source', 'source_date', 'built_at', 'license'});
    expect(meta['source'], 'JMdict_e');
    expect(meta['source_date'], '2024-03-05');
    expect(DateTime.parse(meta['built_at']!).isUtc, isTrue);
    expect(
      meta['license'],
      'JMdict © Electronic Dictionary Research and Development Group, '
      'CC BY-SA 4.0',
    );
  });

  test('the gzip decompresses to the valid database', () {
    final restored = File(p.join(tmp.path, 'restored.db'))
      ..writeAsBytesSync(gzip.decode(File(gzPath).readAsBytesSync()));
    final copy = sqlite3.open(restored.path, mode: OpenMode.readOnly);
    addTearDown(copy.close);
    expect(copy.select('PRAGMA integrity_check').single.columnAt(0), 'ok');
    expect(copy.select('SELECT COUNT(*) FROM entries').single.columnAt(0), 8);
    expect(copy.select('SELECT COUNT(*) FROM terms').single.columnAt(0), 22);
  });

  test('writes a version file with the gzip SHA-256 and length', () {
    final gzBytes = File(gzPath).readAsBytesSync();
    final line = '${sha256.convert(gzBytes)} ${gzBytes.length}';
    final versionFile = File(versionPathFor(gzPath));

    expect(versionFile.path, p.join(tmp.path, 'jmdict.version'));
    expect(versionFile.readAsStringSync(), '$line\n');
    expect(stats.fingerprint, line);
    expect(line, matches(RegExp(r'^[0-9a-f]{64} \d+$')));
    expect(line, endsWith(' ${stats.gzBytes}'));
  });

  test('the version file sits next to the gzip', () {
    expect(
      versionPathFor('assets/dict/jmdict.db.gz'),
      'assets/dict/jmdict.version',
    );
    expect(versionPathFor('out/JMdict_e.gz'), 'out/JMdict_e.version');
  });

  test('writeVersionFile fingerprints an existing gzip', () async {
    final existing = File(p.join(tmp.path, 'existing.db.gz'))
      ..writeAsBytesSync([1, 2, 3]);
    const line =
        '039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81 3';

    expect(await writeVersionFile(existing.path), line);
    expect(
      File(p.join(tmp.path, 'existing.version')).readAsStringSync(),
      '$line\n',
    );
  });

  test('the bundled asset matches its committed version file', () {
    final gz = File('assets/dict/jmdict.db.gz').readAsBytesSync();
    final expected = '${sha256.convert(gz)} ${gz.length}';
    final versionContent = File('assets/dict/jmdict.version')
        .readAsStringSync()
        .replaceAll('\r\n', '\n')
        .trim();
    expect(versionContent, expected);
  });

  test('reads gzipped XML', () async {
    final gzXml = File(p.join(tmp.path, 'JMdict_e.gz'))
      ..writeAsBytesSync(gzip.encode(File(_fixture).readAsBytesSync()));
    final result = await buildFromJmdictXml(
      gzXml.path,
      dbPath: p.join(tmp.path, 'from_gz.db'),
      gzPath: p.join(tmp.path, 'from_gz.db.gz'),
    );
    expect(result.entries, 8);
    expect(result.terms, 22);
  });

  test('--common-only keeps only common entries and their terms', () async {
    final result = await buildFromJmdictXml(
      _fixture,
      dbPath: p.join(tmp.path, 'common.db'),
      gzPath: p.join(tmp.path, 'common.db.gz'),
      commonOnly: true,
    );
    expect(result.entries, 6);
    expect(result.terms, 19);

    final common = sqlite3.open(
      p.join(tmp.path, 'common.db'),
      mode: OpenMode.readOnly,
    );
    addTearDown(common.close);
    final ids = [
      for (final row in common.select('SELECT id FROM entries ORDER BY id'))
        row['id'] as int,
    ];
    expect(ids, [1219950, 1358280, 1464530, 1578850, 1582710, 1628530]);
    expect(
      common
          .select(
            'SELECT COUNT(*) FROM terms WHERE entry_id NOT IN (SELECT id FROM entries)',
          )
          .single
          .columnAt(0),
      0,
    );
  });

  group('from a jamdict database', () {
    late String jamdictPath;

    setUpAll(() {
      jamdictPath = p.join(tmp.path, 'jamdict.db');
      final jamdict = sqlite3.open(jamdictPath);
      jamdict.execute('''
        CREATE TABLE meta(key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL);
        CREATE TABLE Entry(idseq INTEGER NOT NULL UNIQUE);
        CREATE TABLE Kanji(ID INTEGER PRIMARY KEY, idseq INTEGER, text TEXT);
        CREATE TABLE KJP(kid INTEGER, text TEXT);
        CREATE TABLE Kana(ID INTEGER PRIMARY KEY, idseq INTEGER, text TEXT, nokanji BOOLEAN);
        CREATE TABLE KNP(kid INTEGER, text TEXT);
        CREATE TABLE Sense(ID INTEGER PRIMARY KEY, idseq INTEGER);
        CREATE TABLE pos(sid INTEGER, text TEXT);
        CREATE TABLE field(sid INTEGER, text TEXT);
        CREATE TABLE misc(sid INTEGER, text TEXT);
        CREATE TABLE dialect(sid INTEGER, text TEXT);
        CREATE TABLE SenseGloss(sid INTEGER, lang TEXT, gend TEXT, text TEXT);

        INSERT INTO meta VALUES ('jmnedict.date', '2020-05-29');
        INSERT INTO Entry VALUES (10), (20);
        -- Entry 10: kanji tagged nf25 only (not common), kana tagged news1.
        INSERT INTO Kanji VALUES (1, 10, '漢字');
        INSERT INTO KJP VALUES (1, 'nf25');
        INSERT INTO Kana VALUES (1, 10, 'かんじ', 0), (2, 10, 'カンジ', 0);
        INSERT INTO KNP VALUES (1, 'news1');
        INSERT INTO Sense VALUES (1, 10), (2, 10);
        INSERT INTO pos VALUES (1, 'noun (common) (futsuumeishi)');
        INSERT INTO field VALUES (1, 'computing');
        INSERT INTO misc VALUES (1, 'colloquialism');
        INSERT INTO dialect VALUES (1, 'Kansai-ben');
        INSERT INTO SenseGloss VALUES
          (1, 'eng', NULL, 'kanji'), (1, 'ger', NULL, 'Kanji'),
          (2, 'eng', NULL, 'Chinese character');
        -- Entry 20: kana only, no priority.
        INSERT INTO Kana VALUES (3, 20, 'はい', 0);
        INSERT INTO Sense VALUES (3, 20);
        INSERT INTO pos VALUES (3, 'interjection (kandoushi)');
        INSERT INTO SenseGloss VALUES (3, 'eng', NULL, 'yes');
      ''');
      jamdict.close();
    });

    test('produces the same schema, entries and terms', () async {
      final result = await buildFromJamdict(
        jamdictPath,
        dbPath: p.join(tmp.path, 'from_jamdict.db'),
        gzPath: p.join(tmp.path, 'from_jamdict.db.gz'),
      );
      expect(result.entries, 2);
      expect(result.terms, 4);

      final built = sqlite3.open(
        p.join(tmp.path, 'from_jamdict.db'),
        mode: OpenMode.readOnly,
      );
      addTearDown(built.close);
      final json = {
        for (final row in built.select('SELECT id, json FROM entries'))
          row['id'] as int: _jsonOf(row['json'] as String),
      };
      expect(json[10], {
        'k': ['漢字'],
        'r': ['かんじ', 'カンジ'],
        's': [
          {
            'p': ['noun (common) (futsuumeishi)'],
            'g': ['kanji'],
            'm': ['computing', 'colloquialism', 'Kansai-ben'],
          },
          {
            // Inherits pos from the sense before it.
            'p': ['noun (common) (futsuumeishi)'],
            'g': ['Chinese character'],
          },
        ],
        'c': true,
      });
      expect(json[20], {
        'r': ['はい'],
        's': [
          {
            'p': ['interjection (kandoushi)'],
            'g': ['yes'],
          },
        ],
      });
      expect(
        {
          for (final row in built.select(
            'SELECT term, priority FROM terms WHERE entry_id = 10',
          ))
            row['term'] as String: row['priority'] as int,
        },
        {'漢字': 0, 'かんじ': 1, 'カンジ': 0},
      );
      expect(
        built
            .select("SELECT value FROM meta WHERE key = 'source_date'")
            .single
            .columnAt(0),
        '2020-05-29',
      );
    });
  });
}
