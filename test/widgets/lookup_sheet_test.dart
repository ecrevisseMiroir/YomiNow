import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/dictionary_entry.dart';
import 'package:yominow/models/lookup_result.dart';
import 'package:yominow/widgets/lookup_sheet.dart';

import '../fakes.dart';

const _attribution = 'Dictionary data: JMdict © EDRDG, CC BY-SA 4.0';

const _taberu = DictionaryEntry(
  id: 1358280,
  kanji: ['食べる', '喰べる'],
  readings: ['たべる', 'タベル'],
  senses: [
    Sense(pos: ['Ichidan verb', 'transitive verb'], glosses: ['to eat']),
    Sense(pos: ['Ichidan verb'], glosses: ['to live on', 'to subsist on']),
  ],
  common: true,
);

const _kanaOnly = DictionaryEntry(
  id: 2,
  kanji: [],
  readings: ['ふりがな'],
  senses: [
    Sense(pos: [], glosses: ['furigana']),
  ],
);

LookupResult _match(List<DictionaryEntry> entries, {String text = '食べ'}) =>
    LookupResult(
      matchedText: text,
      start: 0,
      end: text.length,
      reading: 'たべ',
      entries: entries,
    );

void main() {
  /// Opens a [LookupSheet] for [result] from a button, on a tall screen by
  /// default so the whole sheet is laid out.
  ///
  /// Does not settle, since the loading state animates forever.
  Future<void> showSheet(
    WidgetTester tester,
    Future<LookupResult?> result, {
    Size size = const Size(800, 1600),
    AddToAnkiCallback? onAddToAnki,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      withServices(
        fakeServices(),
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    LookupSheet.show(context, result, onAddToAnki: onAddToAnki),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // route animation
  }

  testWidgets('shows the match, reading and every entry', (tester) async {
    await showSheet(tester, Future.value(_match([_taberu, _kanaOnly])));

    // Match and its reading.
    expect(find.text('食べ'), findsOneWidget);
    expect(find.text('たべ'), findsOneWidget);
    // Headword, other kanji forms, other readings, common chip.
    expect(find.text('食べる'), findsOneWidget);
    expect(find.text('喰べる'), findsOneWidget);
    expect(find.text('たべる、タベル'), findsOneWidget);
    expect(find.text('common'), findsOneWidget);
    // Numbered senses, glosses joined by "; ".
    expect(find.text('1.'), findsNWidgets(2));
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('to eat'), findsOneWidget);
    expect(find.text('to live on; to subsist on'), findsOneWidget);
    // A kana-only entry shows its headword once and no readings line.
    expect(find.text('ふりがな'), findsOneWidget);
    expect(find.text('furigana'), findsOneWidget);
    expect(find.text(_attribution), findsOneWidget);
  });

  testWidgets('Add to Anki passes the complete lookup result', (tester) async {
    final match = _match([_taberu]);
    LookupResult? addedResult;
    await showSheet(
      tester,
      Future.value(match),
      onAddToAnki: (result) => addedResult = result,
    );

    await tester.tap(find.text('Add to Anki'));

    expect(identical(addedResult, match), isTrue);
    expect(addedResult?.entries.single.senses.first.glosses, ['to eat']);
  });

  testWidgets('parts of speech are small, muted and italic', (tester) async {
    await showSheet(tester, Future.value(_match([_taberu])));

    final pos = tester.widget<Text>(find.text('Ichidan verb, transitive verb'));
    final gloss = tester.widget<Text>(find.text('to eat'));
    expect(pos.style?.fontStyle, FontStyle.italic);
    expect(pos.style?.fontSize, lessThan(gloss.style!.fontSize!));
    expect(pos.style?.color, isNot(gloss.style?.color));
  });

  testWidgets('says so when there is no entry', (tester) async {
    await showSheet(tester, Future.value(_match([], text: 'ほげ')));

    expect(find.text('ほげ'), findsOneWidget);
    expect(find.text('No dictionary entry for 「ほげ」'), findsOneWidget);
    expect(find.text(_attribution), findsOneWidget);
  });

  testWidgets('shows a spinner until the lookup completes', (tester) async {
    final lookup = Completer<LookupResult?>();
    await showSheet(tester, lookup.future);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(_attribution), findsOneWidget);

    lookup.complete(_match([_taberu]));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('to eat'), findsOneWidget);
  });

  testWidgets('a null result says there is no word here', (tester) async {
    await showSheet(tester, Future.value(null));

    expect(find.text('No word to look up here.'), findsOneWidget);
    expect(find.text(_attribution), findsOneWidget);
  });

  testWidgets('a failed lookup shows the error', (tester) async {
    // ignore() keeps the error from being reported as unhandled before the
    // sheet starts listening.
    final failure = Future<LookupResult?>.error(
      StateError('dictionary missing'),
    )..ignore();
    await showSheet(tester, failure);

    expect(find.textContaining('Lookup failed'), findsOneWidget);
    expect(find.textContaining('dictionary missing'), findsOneWidget);
  });

  testWidgets('long results scroll inside the sheet', (tester) async {
    final entries = [
      for (var i = 0; i < 30; i++)
        DictionaryEntry(
          id: i,
          kanji: ['語$i'],
          readings: ['ご$i'],
          senses: [
            Sense(pos: const ['noun'], glosses: ['word $i']),
          ],
        ),
    ];
    await showSheet(
      tester,
      Future.value(_match(entries)),
      size: const Size(800, 800),
    );

    // The last entry is laid out but scrolled out of view.
    final last = find.text('word 29').hitTestable();
    expect(last, findsNothing);
    await tester.scrollUntilVisible(
      last,
      500,
      scrollable: find.descendant(
        of: find.byType(LookupSheet),
        matching: find.byType(Scrollable),
      ),
    );
    expect(last, findsOneWidget);
    // The attribution stays pinned below the list.
    expect(find.text(_attribution), findsOneWidget);
  });

  testWidgets('dragging the sheet down dismisses it', (tester) async {
    await showSheet(tester, Future.value(_match([_taberu])));
    expect(find.byType(LookupSheet), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 800), 2000);
    await tester.pumpAndSettle();

    expect(find.byType(LookupSheet), findsNothing);
  });

  testWidgets('tapping outside the sheet dismisses it', (tester) async {
    await showSheet(tester, Future.value(_match([_taberu])));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(LookupSheet), findsNothing);
  });
}
