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

    expect(find.text('Documents'), findsNWidgets(2));
    expect(find.text('No Documents Yet'), findsOneWidget);
  });
}
