import 'package:flutter/services.dart';

enum AnkiDroidAddResult { added, duplicate, shared }

class AnkiDroidService {
  // TODO here we need to change the channel name to something more generic, since this service is not only for AnkiDroid but also for other apps that support the AnkiConnect protocol.
  static const _channel = MethodChannel(
    'io.github.ecrevissemiroir.yominow/anki',
  );

  Future<bool> isDuplicate(String word) async {
    return await _channel.invokeMethod<bool>('isDuplicate', {'word': word}) ??
        false;
  }

  Future<AnkiDroidAddResult> addNote({
    required String word,
    required String back,
  }) async {
    final result = await _channel.invokeMethod<String>('addNote', {
      'word': word,
      'back': back,
    });
    return switch (result) {
      'added' => AnkiDroidAddResult.added,
      'duplicate' => AnkiDroidAddResult.duplicate,
      'shared' => AnkiDroidAddResult.shared,
      _ => throw PlatformException(
        code: 'INVALID_ANKIDROID_RESULT',
        message: 'AnkiDroid returned an unknown add result.',
      ),
    };
  }
}
