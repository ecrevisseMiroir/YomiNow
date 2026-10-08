import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    // 1. Ensure the TTS engine treats ja-JP as an explicit requirement
    await _tts.setLanguage('ja-JP');

    // 2. On Android, force the default engine to wait for language availability
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // 3. Find and explicitly assign an installed Japanese voice if available
    try {
      List<dynamic> voices = await _tts.getVoices;
      for (var voice in voices) {
        if (voice is Map) {
          String locale = voice['locale']?.toString() ?? '';
          if (locale.contains('ja') ||
              locale.contains('ja_JP') ||
              locale.contains('ja-JP')) {
            await _tts.setVoice({
              "name": voice["name"],
              "locale": voice["locale"],
            });
            break;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching voices: $e");
      }
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
