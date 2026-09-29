import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:yominow/models/dictionary_entry.dart';
import 'package:yominow/services/sqlite_dictionary_service.dart';

import '../../tool/src/jmdict_builder.dart';

List<int> _ids(Iterable<DictionaryEntry> entries) => [
  for (final entry in entries) entry.id,
];

void main() {
  late Directory tmp;
  late String dbPath;
  late SqliteDictionaryService service;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('sqlite_dictionary_test');
    dbPath = p.join(tmp.path, 'jmdict.db');
    await buildFromJmdictXml(
      'test/fixtures/jmdict_sample.xml',
      dbPath: dbPath,
      gzPath: p.join(tmp.path, 'jmdict.db.gz'),
    );
  });

  tearDownAll(() => tmp.deleteSync(recursive: true));

  setUp(
    () => service = SqliteDictionaryService(databasePath: () async => dbPath),
  );

  tearDown(() => service.close());

  group('lookup', () {
    test('finds an entry by kanji form', () async {
      final entries = await service.lookup('食べる');
      expect(_ids(entries), [1358280]);
      final entry = entries.single;
      expect(entry.headword, '食べる');
      expect(entry.kanji, ['食べる', '喰べる']);
      expect(entry.readings, ['たべる']);
      expect(entry.common, isTrue);
      expect(entry.senses.first.glosses, ['to eat']);
    });

    test('finds entries by kana reading, common first', () async {
      final entries = await service.lookup('これ');
      expect(_ids(entries), [1628530, 2216120]);
      expect(entries.first.headword, '此れ');
      expect(entries.last.kanji, isEmpty);
      expect(entries.last.headword, 'これ');
    });

    test('orders by priority, then entry id', () async {
      // 幾 (1219950) and 行く (1578850) are common; 畏懼 (1157500) has the
      // lowest id but is not.
      expect(_ids(await service.lookup('いく')), [1219950, 1578850, 1157500]);
    });

    test('honours the limit', () async {
      expect(_ids(await service.lookup('いく', limit: 2)), [1219950, 1578850]);
    });

    test('returns an empty list for unknown terms', () async {
      expect(await service.lookup('存在しない'), isEmpty);
      expect(await service.lookup(''), isEmpty);
    });

    test('matches whole terms only', () async {
      expect(await service.lookup('日'), isEmpty);
      expect(_ids(await service.lookup('日本')), [1582710]);
    });

    test('returns each entry once, at its highest priority', () async {
      final copy = p.join(tmp.path, 'duplicates.db');
      File(dbPath).copySync(copy);
      final db = sqlite3.open(copy);
      // A repeated row for the uncommon 畏懼 entry, this time with priority.
      db.execute("INSERT INTO terms VALUES ('いく', 1157500, 1)");
      db.execute("INSERT INTO terms VALUES ('いく', 1157500, 0)");
      db.close();

      final duplicated = SqliteDictionaryService(
        databasePath: () async => copy,
      );
      addTearDown(duplicated.close);
      expect(_ids(await duplicated.lookup('いく')), [1157500, 1219950, 1578850]);
    });
  });

  group('longestMatch', () {
    test('prefers the longest term: 日本語を', () async {
      final match = await service.longestMatch('日本語を', 0);
      expect(match?.term, '日本語');
      expect(_ids(match!.entries), [1464530]);
    });

    test('falls back to a shorter term: 日本人', () async {
      final match = await service.longestMatch('日本人', 0);
      expect(match?.term, '日本');
      expect(_ids(match!.entries), [1582710]);
    });

    test('matches kana and returns every entry of the term', () async {
      final match = await service.longestMatch('これはペンです', 0);
      expect(match?.term, 'これ');
      expect(_ids(match!.entries), [1628530, 2216120]);
    });

    test('starts at from', () async {
      expect(await service.longestMatch('を日本語', 0), isNull);
      expect((await service.longestMatch('を日本語', 1))?.term, '日本語');
      expect((await service.longestMatch('私は食べる', 2))?.term, '食べる');
    });

    test('never matches beyond maxLength', () async {
      expect((await service.longestMatch('日本語', 0, maxLength: 2))?.term, '日本');
      expect(await service.longestMatch('日本語', 0, maxLength: 1), isNull);
      expect(await service.longestMatch('日本語', 0, maxLength: 0), isNull);
    });

    test('returns null when nothing matches', () async {
      expect(await service.longestMatch('存在しない', 0), isNull);
    });

    test('returns null when from is out of range', () async {
      expect(await service.longestMatch('日本語', 3), isNull);
      expect(await service.longestMatch('日本語', 99), isNull);
      expect(await service.longestMatch('日本語', -1), isNull);
      expect(await service.longestMatch('', 0), isNull);
    });

    test('handles characters outside the BMP', () async {
      expect(await service.longestMatch('𠮷野家', 0), isNull);
      expect((await service.longestMatch('𠮷日本', 2))?.term, '日本');
    });
  });

  group('lifecycle', () {
    test('open is idempotent and looks the path up once', () async {
      var calls = 0;
      final counted = SqliteDictionaryService(
        databasePath: () async {
          calls++;
          return dbPath;
        },
      );
      addTearDown(counted.close);

      await Future.wait([counted.open(), counted.open()]);
      await counted.open();
      await counted.lookup('日本');
      expect(calls, 1);
    });

    test('lookups open the database implicitly', () async {
      expect(_ids(await service.lookup('日本語')), [1464530]);
    });

    test('can be used again after close', () async {
      await service.lookup('日本');
      await service.close();
      await service.close();
      expect(_ids(await service.lookup('日本')), [1582710]);
    });

    test('a failed open can be retried', () async {
      var path = p.join(tmp.path, 'missing.db');
      final flaky = SqliteDictionaryService(databasePath: () async => path);
      addTearDown(flaky.close);

      await expectLater(flaky.open(), throwsA(isA<SqliteException>()));
      path = dbPath;
      expect(_ids(await flaky.lookup('日本')), [1582710]);
    });
  });

  group('bundled asset', () {
    const assetKey = 'assets/dict/jmdict.db.gz';
    late Directory support;
    late File extracted;
    late File marker;

    /// Opens a default-constructed service and closes it again.
    Future<List<DictionaryEntry>> useBundled() async {
      final bundled = SqliteDictionaryService();
      try {
        return await bundled.lookup('食べる');
      } finally {
        await bundled.close();
      }
    }

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      support = Directory.systemTemp.createTempSync('support_dir');
      extracted = File(p.join(support.path, 'dict', 'jmdict.db'));
      marker = File('${extracted.path}.version');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => support.path,
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
      support.deleteSync(recursive: true);
    });

    test('is extracted on first use and reused afterwards', () async {
      final entries = await useBundled();
      expect(entries.single.senses.first.glosses, contains('to eat'));
      expect(extracted.existsSync(), isTrue);
      expect(File('${extracted.path}.partial').existsSync(), isFalse);

      final assetLength = (await rootBundle.load(assetKey)).lengthInBytes;
      expect(marker.readAsStringSync(), startsWith('$assetLength:'));

      // A second start must not extract again.
      final longAgo = DateTime(2000);
      extracted.setLastModifiedSync(longAgo);
      expect(_ids(await useBundled()), [1358280]);
      expect(extracted.lastModifiedSync(), longAgo);
    });

    test('is extracted again when the marker does not match', () async {
      await useBundled();
      final fingerprint = marker.readAsStringSync();

      extracted.setLastModifiedSync(DateTime(2000));
      marker.writeAsStringSync('12345:0000000000000000');
      expect(_ids(await useBundled()), [1358280]);
      expect(extracted.lastModifiedSync().year, greaterThan(2000));
      expect(marker.readAsStringSync(), fingerprint);
    });

    test('is extracted again when the database or marker is missing', () async {
      await useBundled();
      extracted.deleteSync();
      expect(_ids(await useBundled()), [1358280]);

      marker.deleteSync();
      extracted.setLastModifiedSync(DateTime(2000));
      expect(_ids(await useBundled()), [1358280]);
      expect(extracted.lastModifiedSync().year, greaterThan(2000));
      expect(marker.existsSync(), isTrue);
    });
  });
}
