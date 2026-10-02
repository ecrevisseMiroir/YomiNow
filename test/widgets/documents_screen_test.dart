import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/screens/documents_screen.dart';

import '../fakes.dart';

void main() {
  testWidgets('documents screen shows the document tabs and list', (
    tester,
  ) async {
    await tester.pumpWidget(
      withServices(fakeServices(), const DocumentsScreen()),
    );

    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.textContaining('東京の観光ガイド'), findsOneWidget);
  });
}
