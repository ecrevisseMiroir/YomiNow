import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LookupRecord {
  const LookupRecord({
    required this.word,
    required this.reading,
    required this.gloss,
    required this.createdAt,
  });

  final String word;
  final String reading;
  final String gloss;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'word': word,
    'reading': reading,
    'gloss': gloss,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LookupRecord.fromJson(Map<String, dynamic> json) => LookupRecord(
    word: json['word'] as String,
    reading: json['reading'] as String,
    gloss: json['gloss'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class LookupHistory extends ChangeNotifier {
  LookupHistory._();
  static final instance = LookupHistory._();

  static const _key = 'lookup_history';
  static const _max = 50;

  List<LookupRecord> _records = [];
  bool _loaded = false;

  List<LookupRecord> get records => List.unmodifiable(_records);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _records = raw
        .map(
          (e) => LookupRecord.fromJson(jsonDecode(e) as Map<String, dynamic>),
        )
        .toList();
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(LookupRecord record) async {
    await load();
    _records = [record, ..._records].take(_max).toList();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _records.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }
}
