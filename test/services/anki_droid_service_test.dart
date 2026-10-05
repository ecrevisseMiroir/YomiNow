import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/services/anki_droid_service.dart';

const _channel = MethodChannel('io.github.ecrevissemiroir.yominow/anki');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  var response = 'added';

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return response;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('preserves the duplicate result and sends the card fields', () async {
    response = 'duplicate';

    final outcome = await AnkiDroidService().addNote(
      word: '日本語',
      back: 'にほんご\nJapanese (language)',
    );

    expect(outcome, AnkiDroidAddResult.duplicate);
    expect(calls, hasLength(1));
    expect(calls.single.method, 'addNote');
    expect(calls.single.arguments, {
      'word': '日本語',
      'back': 'にほんご\nJapanese (language)',
    });
  });

  test('distinguishes direct adds from the AnkiDroid handoff', () async {
    final service = AnkiDroidService();

    response = 'added';
    expect(
      await service.addNote(word: '読む', back: 'よむ\nto read'),
      AnkiDroidAddResult.added,
    );

    response = 'shared';
    expect(
      await service.addNote(word: '食べる', back: 'たべる\nto eat'),
      AnkiDroidAddResult.shared,
    );
  });
}
