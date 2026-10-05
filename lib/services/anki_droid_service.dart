import 'package:flutter/services.dart';

class AnkiDroidService {
  static const _channel = MethodChannel(
    'io.github.ecrevissemiroir.yominow/anki',
  );

  Future<bool> addNote({required String word, required String back}) async {
    final result = await _channel.invokeMethod<String>('addNote', {
      'word': word,
      'back': back,
    });
    return result == 'added';
  }
}
