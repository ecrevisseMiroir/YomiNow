/// Converts katakana (ァ–ヶ) in [s] to hiragana (ぁ–ゖ). The long-vowel mark ー
/// and all other characters are kept unchanged.
String katakanaToHiragana(String s) => String.fromCharCodes([
  for (final c in s.codeUnits) c >= 0x30A1 && c <= 0x30F6 ? c - 0x60 : c,
]);

/// Whether [codeUnitOrRune] is a kanji: a CJK ideograph (including the
/// extension blocks and compatibility ideographs) or the iteration mark 々.
///
/// Pass a rune to test characters outside the BMP.
bool isKanji(int codeUnitOrRune) =>
    codeUnitOrRune == 0x3005 ||
    (codeUnitOrRune >= 0x3400 && codeUnitOrRune <= 0x4DBF) ||
    (codeUnitOrRune >= 0x4E00 && codeUnitOrRune <= 0x9FFF) ||
    (codeUnitOrRune >= 0xF900 && codeUnitOrRune <= 0xFAFF) ||
    (codeUnitOrRune >= 0x20000 && codeUnitOrRune <= 0x2FA1F);

/// Whether [s] contains at least one kanji.
bool containsKanji(String s) => s.runes.any(isKanji);

/// Whether [s] is non-empty and made up only of hiragana, katakana and the
/// long-vowel mark ー.
bool isKana(String s) => s.isNotEmpty && s.runes.every(_isKanaRune);

bool _isKanaRune(int rune) =>
    (rune >= 0x3041 && rune <= 0x3096) || // hiragana
    (rune >= 0x30A1 && rune <= 0x30FA) || // katakana
    rune == 0x30FC; // ー
