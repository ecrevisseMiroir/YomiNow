import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/scanned_document.dart';

abstract interface class DocumentRepository {
  Future<List<ScannedDocument>> getAll();

  Future<ScannedDocument> addImage(XFile source);

  Future<void> updateHasText(String id, bool hasText);

  Future<void> delete(String id);
}

class SqliteDocumentRepository implements DocumentRepository {
  SqliteDocumentRepository({Future<Directory> Function()? supportDirectory})
    : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDirectory;
  Future<Database>? _opening;

  Future<Database> get _database => _opening ??= _openDatabase();

  Future<Database> _openDatabase() async {
    try {
      final support = await _supportDirectory();
      final directory = Directory(p.join(support.path, 'documents'));
      await directory.create(recursive: true);
      final database = sqlite3.open(p.join(directory.path, 'scans.sqlite'));
      database.execute('''
        CREATE TABLE IF NOT EXISTS scanned_documents (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          path TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          has_text INTEGER NOT NULL DEFAULT 0
        )
      ''');
      return database;
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  @override
  Future<List<ScannedDocument>> getAll() async {
    final rows = (await _database).select(
      'SELECT id, title, path, created_at, has_text '
      'FROM scanned_documents ORDER BY created_at DESC',
    );
    return [for (final row in rows) _documentFromRow(row)];
  }

  @override
  Future<ScannedDocument> addImage(XFile source) async {
    final support = await _supportDirectory();
    final directory = Directory(p.join(support.path, 'documents', 'images'));
    await directory.create(recursive: true);

    final now = DateTime.now();
    final id =
        '${now.microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    final extension = p.extension(source.name).isEmpty
        ? '.jpg'
        : p.extension(source.name).toLowerCase();
    final savedPath = p.join(directory.path, '$id$extension');
    final title = source.name.isNotEmpty
        ? source.name
        : p.basename(source.path);

    await File(source.path).copy(savedPath);
    try {
      (await _database).execute(
        'INSERT INTO scanned_documents (id, title, path, created_at, has_text) '
        'VALUES (?, ?, ?, ?, 0)',
        [id, title, savedPath, now.millisecondsSinceEpoch],
      );
    } catch (_) {
      await File(savedPath).delete();
      rethrow;
    }

    return ScannedDocument(
      id: id,
      title: title,
      path: savedPath,
      createdAt: now,
    );
  }

  @override
  Future<void> updateHasText(String id, bool hasText) async {
    (await _database).execute(
      'UPDATE scanned_documents SET has_text = ? WHERE id = ?',
      [hasText ? 1 : 0, id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final database = await _database;
    final rows = database.select(
      'SELECT path FROM scanned_documents WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return;

    final path = rows.first['path'] as String;
    database.execute('DELETE FROM scanned_documents WHERE id = ?', [id]);
    final image = File(path);
    if (await image.exists()) await image.delete();
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening == null) return;
    final database = await opening;
    database.close();
  }
}

ScannedDocument _documentFromRow(Row row) => ScannedDocument(
  id: row['id'] as String,
  title: row['title'] as String,
  path: row['path'] as String,
  createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
  hasText: (row['has_text'] as int) != 0,
);
