/// One sense (meaning group) of a JMdict entry.
class Sense {
  const Sense({
    required this.pos,
    required this.glosses,
    this.misc = const [],
  });

  /// Part-of-speech codes as JMdict entity names, e.g. `n`, `v5r`, `adj-i`.
  final List<String> pos;

  /// English glosses.
  final List<String> glosses;

  /// Misc codes as JMdict entity names, e.g. `uk`, `abbr`.
  final List<String> misc;

  factory Sense.fromJson(Map<String, dynamic> json) => Sense(
        pos: _strings(json['p']),
        glosses: _strings(json['g']),
        misc: _strings(json['m']),
      );

  Map<String, dynamic> toJson() => {
        'p': pos,
        'g': glosses,
        if (misc.isNotEmpty) 'm': misc,
      };
}

/// A JMdict entry. The compact JSON form ([toJson]/[fromJson]) is what the
/// dictionary database stores in `entries.json`:
/// `{"k": [...], "r": [...], "s": [{"p": [...], "g": [...], "m": [...]}], "c": true}`
class DictionaryEntry {
  const DictionaryEntry({
    required this.id,
    required this.kanji,
    required this.readings,
    required this.senses,
    this.common = false,
  });

  /// JMdict `ent_seq`.
  final int id;

  /// Kanji forms (`keb`); empty for kana-only words.
  final List<String> kanji;

  /// Kana readings (`reb`).
  final List<String> readings;

  final List<Sense> senses;

  /// True when any form carries a news1/ichi1/spec1/spec2/gai1 priority tag.
  final bool common;

  factory DictionaryEntry.fromJson(int id, Map<String, dynamic> json) =>
      DictionaryEntry(
        id: id,
        kanji: _strings(json['k']),
        readings: _strings(json['r']),
        senses: [
          for (final s in (json['s'] as List? ?? const []))
            Sense.fromJson(s as Map<String, dynamic>),
        ],
        common: json['c'] == true,
      );

  Map<String, dynamic> toJson() => {
        if (kanji.isNotEmpty) 'k': kanji,
        'r': readings,
        's': [for (final s in senses) s.toJson()],
        if (common) 'c': true,
      };

  /// Headword to display: first kanji form, else first reading.
  String get headword => kanji.isNotEmpty ? kanji.first : readings.first;
}

List<String> _strings(Object? v) =>
    v == null ? const [] : [for (final e in v as List) e as String];
