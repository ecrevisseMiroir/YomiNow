import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/dictionary_entry.dart';
import 'dictionary_service.dart';

const _assetKey = 'assets/dict/jmdict.db.gz';

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
  /// `assets/dict/jmdict.db.gz` is extracted to the application support
  /// directory, again whenever the asset changes.
  SqliteDictionaryService({Future<String> Function()? databasePath})
    : _databasePath = databasePath ?? _extractBundledDatabase;

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
/// `<application support>/dict/jmdict.db` and returns its path. Extraction
/// is skipped when a marker file next to the database says it came from the
/// current asset.
Future<String> _extractBundledDatabase() async {
  final asset = await rootBundle.load(_assetKey);
  final gz = asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);
  final fingerprint = _fingerprint(gz);

  final support = await getApplicationSupportDirectory();
  final database = File(p.join(support.path, 'dict', 'jmdict.db'));
  final marker = File('${database.path}.version');
  if (await database.exists() &&
      await marker.exists() &&
      await marker.readAsString() == fingerprint) {
    return database.path;
  }

  // Extract beside the target and rename, so an interrupted run never leaves
  // a truncated database that the marker vouches for.
  await database.parent.create(recursive: true);
  final partial = '${database.path}.partial';
  await _gunzipInBackground(gz, partial);
  await File(partial).rename(database.path);
  await marker.writeAsString(fingerprint);
  return database.path;
}

/// Identifies a gzip file without decompressing it: its length plus the
/// CRC-32 and size of the uncompressed data, which gzip stores in the last
/// eight bytes. A rebuilt database therefore changes the fingerprint even if
/// it happens to compress to the same size.
String _fingerprint(Uint8List gz) {
  final trailer = gz
      .sublist(gz.length - 8)
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${gz.length}:$trailer';
}

Future<void> _gunzipInBackground(Uint8List gz, String path) => Isolate.run(
  () => gzip.decoder.bind(Stream.value(gz)).pipe(File(path).openWrite()),
);
