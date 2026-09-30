import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/ja_token.dart';
import 'package:yominow/services/app_services.dart';
import 'package:yominow/widgets/tokenized_text.dart';

import '../fakes.dart';

JaToken _token(
  String surface,
  int start, {
  String pos = '名詞',
  String? reading,
}) => JaToken(
  surface: surface,
  basicForm: surface,
  reading: reading,
  pos: pos,
  start: start,
  end: start + surface.length,
);

// 日本語を読む。 猫
final _tokens = [
  _token('日本語', 0, reading: 'にほんご'),
  _token('を', 3, pos: '助詞', reading: 'を'),
  _token('読む', 4, pos: '動詞', reading: 'よむ'),
  _token('。', 6, pos: '記号', reading: '。'),
  _token(' ', 7, pos: '記号'),
  _token('猫', 8),
];
const _text = '日本語を読む。 猫';

void main() {
  late FakeTokenizerService tokenizer;
  late AppServices services;
  late List<int> taps;

  Future<void> pumpText(
    WidgetTester tester, {
    String text = _text,
    Duration delay = Duration.zero,
  }) {
    tokenizer = FakeTokenizerService(tokens: {_text: _tokens}, delay: delay);
    services = fakeServices(tokenizer: tokenizer);
    taps = [];
    return tester.pumpWidget(
      withServices(
        services,
        Scaffold(
          body: TokenizedText(text: text, onTapOffset: taps.add),
        ),
      ),
    );
  }

  testWidgets('shows the raw text while tokenizing', (tester) async {
    await pumpText(tester, delay: const Duration(seconds: 1));

    expect(find.text(_text), findsOneWidget);
    expect(find.text('にほんご'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text(_text), findsNothing);
    expect(find.text('日本語'), findsOneWidget);
    expect(tokenizer.tokenized, [_text]);
  });

  testWidgets('shows furigana over kanji words only', (tester) async {
    await pumpText(tester);
    await tester.pump();

    expect(find.text('にほんご'), findsOneWidget);
    expect(find.text('よむ'), findsOneWidget);
    // Kana words keep their reading to themselves, punctuation is plain, and
    // a kanji word without a reading gets nothing above it.
    expect(find.text('を'), findsOneWidget);
    expect(find.text('。'), findsOneWidget);
    expect(find.text('猫'), findsOneWidget);
    final texts = find.descendant(
      of: find.byType(TokenizedText),
      matching: find.byType(Text),
    );
    expect(texts, findsNWidgets(6 + 2)); // 6 tokens, 2 furigana

    final ruby = tester.widget<Text>(find.text('にほんご'));
    final surface = tester.widget<Text>(find.text('日本語'));
    expect(ruby.style!.fontSize, lessThan(surface.style!.fontSize!));
    expect(
      tester.getRect(find.text('にほんご')).bottom,
      lessThanOrEqualTo(tester.getRect(find.text('日本語')).top),
    );
  });

  testWidgets('tapping a word reports its start offset', (tester) async {
    await pumpText(tester);
    await tester.pump();

    await tester.tap(find.text('読む'));
    await tester.tap(find.text('日本語'));
    await tester.tap(find.text('猫'));

    expect(taps, [4, 0, 8]);
  });

  testWidgets('punctuation and spaces are not tappable', (tester) async {
    await pumpText(tester);
    await tester.pump();

    await tester.tap(find.text('。'));

    expect(taps, isEmpty);
    expect(
      find.ancestor(of: find.text('。'), matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('tokenizes again when the text changes', (tester) async {
    await pumpText(tester);
    await tester.pump();

    await tester.pumpWidget(
      withServices(
        services,
        Scaffold(
          body: TokenizedText(text: '猫。', onTapOffset: taps.add),
        ),
      ),
    );
    await tester.pump();

    expect(tokenizer.tokenized, [_text, '猫。']);
    expect(find.text('日本語'), findsNothing);
    expect(find.text('猫'), findsOneWidget);
  });
}
