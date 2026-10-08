import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum YomiNowNotificationKind { success, info, error }

class YomiNowNotificationRecord {
  const YomiNowNotificationRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.kind,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final YomiNowNotificationKind kind;
  final DateTime createdAt;
  final bool isRead;

  YomiNowNotificationRecord copyWith({bool? isRead}) =>
      YomiNowNotificationRecord(
        id: id,
        title: title,
        message: message,
        kind: kind,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'kind': kind.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory YomiNowNotificationRecord.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String?;
    return YomiNowNotificationRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      kind: YomiNowNotificationKind.values.firstWhere(
        (kind) => kind.name == kindName,
        orElse: () => YomiNowNotificationKind.info,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class YomiNowNotificationHistory extends ChangeNotifier {
  YomiNowNotificationHistory._();

  static final instance = YomiNowNotificationHistory._();

  static const _storageKey = 'yominow_notification_history';
  static const _maxRecords = 50;

  List<YomiNowNotificationRecord> _records = const [];
  Future<void>? _loading;
  bool _loaded = false;

  List<YomiNowNotificationRecord> get records => _records;
  int get unreadCount => _records.where((record) => !record.isRead).length;

  Future<void> load() {
    if (_loaded) return Future<void>.value();
    return _loading ??= _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedRecords = preferences.getStringList(_storageKey) ?? const [];
      final records = <YomiNowNotificationRecord>[];
      for (final value in savedRecords) {
        try {
          records.add(
            YomiNowNotificationRecord.fromJson(
              jsonDecode(value) as Map<String, dynamic>,
            ),
          );
        } catch (_) {
          continue;
        }
      }
      _records = records;
      _records = _records.take(_maxRecords).toList(growable: false);
    } catch (_) {
      _records = const [];
    } finally {
      _loaded = true;
      _loading = null;
      notifyListeners();
    }
  }

  Future<void> add({
    required String title,
    required String message,
    required YomiNowNotificationKind kind,
  }) async {
    await load();
    final now = DateTime.now();
    _records = [
      YomiNowNotificationRecord(
        id: now.microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        kind: kind,
        createdAt: now,
      ),
      ..._records,
    ].take(_maxRecords).toList(growable: false);
    notifyListeners();
    await _save();
  }

  Future<void> markAllRead() async {
    await load();
    if (unreadCount == 0) return;
    _records = [for (final record in _records) record.copyWith(isRead: true)];
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    await load();
    if (_records.isEmpty) return;
    _records = const [];
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(_storageKey, [
        for (final record in _records) jsonEncode(record.toJson()),
      ]);
    } catch (_) {
      // Keep in-memory history available when persistence is unavailable.
    }
  }
}
