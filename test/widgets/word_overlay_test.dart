import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/ocr_result.dart';
import 'package:yominow/widgets/word_overlay.dart';

const _result = OcrResult(
  lines: [
    OcrLine(
      text: '日本語',
      words: [
        OcrWord(
          text: '日本',
          bbox: Rect.fromLTRB(20, 10, 60, 30),
          start: 0,
          end: 2,
        ),
        OcrWord(
          text: '語',
          bbox: Rect.fromLTRB(62, 10, 80, 30),
          start: 2,
          end: 3,
        ),
      ],
    ),
    OcrLine(
      text: '猫',
      words: [
        OcrWord(
          text: '猫',
          bbox: Rect.fromLTRB(20, 50, 40, 90),
          start: 0,
          end: 1,
        ),
      ],
    ),
  ],
);

Key _key(int line, int word) => ValueKey('word-$line-$word');

WordBoxState _stateOf(WidgetTester tester, int line, int word) =>
    tester.widget<WordBox>(find.byKey(_key(line, word))).state;

void main() {
  // 200x100 image shown at 400x200: every coordinate doubles.
  Future<void> pumpOverlay(
    WidgetTester tester, {
    WordId? selected,
    Set<WordId> highlighted = const {},
    void Function(int, int)? onWordTap,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            key: const Key('image'),
            width: 400,
            height: 200,
            child: WordOverlay(
              result: _result,
              imageSize: const Size(200, 100),
              selected: selected,
              highlighted: highlighted,
              onWordTap: onWordTap ?? (_, _) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('scales image-pixel boxes to the displayed size', (tester) async {
    await pumpOverlay(tester);

    expect(find.byType(WordBox), findsNWidgets(3));
    expect(
      tester.getRect(find.byKey(_key(0, 0))),
      const Rect.fromLTRB(40, 20, 120, 60),
    );
    expect(
      tester.getRect(find.byKey(_key(0, 1))),
      const Rect.fromLTRB(124, 20, 160, 60),
    );
    expect(
      tester.getRect(find.byKey(_key(1, 0))),
      const Rect.fromLTRB(40, 100, 80, 180),
    );
  });

  testWidgets('keeps boxes on their words when the size changes', (
    tester,
  ) async {
    await pumpOverlay(tester);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100,
            height: 50,
            child: WordOverlay(
              result: _result,
              imageSize: const Size(200, 100),
              onWordTap: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getRect(find.byKey(_key(0, 0))),
      const Rect.fromLTRB(10, 5, 30, 15),
    );
  });

  testWidgets('draws selected, highlighted and normal words differently', (
    tester,
  ) async {
    await pumpOverlay(
      tester,
      selected: (line: 0, word: 0),
      highlighted: {(line: 0, word: 0), (line: 0, word: 1)},
    );

    expect(_stateOf(tester, 0, 0), WordBoxState.selected);
    expect(_stateOf(tester, 0, 1), WordBoxState.highlighted);
    expect(_stateOf(tester, 1, 0), WordBoxState.normal);

    Color? fill(int line, int word) =>
        ((tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: find.byKey(_key(line, word)),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration)
                as BoxDecoration)
            .color;
    expect({fill(0, 0), fill(0, 1), fill(1, 0)}, hasLength(3));
  });

  testWidgets('tapping a box reports its line and word index', (tester) async {
    final taps = <(int, int)>[];
    await pumpOverlay(
      tester,
      onWordTap: (line, word) => taps.add((line, word)),
    );

    await tester.tap(find.byKey(_key(0, 1)));
    await tester.tap(find.byKey(_key(1, 0)));

    expect(taps, [(0, 1), (1, 0)]);
  });

  testWidgets('a box is a button labelled with its word', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpOverlay(tester, selected: (line: 1, word: 0));

    expect(find.bySemanticsLabel('日本'), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(_key(1, 0))),
      matchesSemantics(
        label: '猫',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
