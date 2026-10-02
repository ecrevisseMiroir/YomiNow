import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/screens/about_screen.dart';

import '../fakes.dart';

void main() {
  testWidgets('about screen shows the brand and links', (tester) async {
    await tester.pumpWidget(withServices(fakeServices(), const AboutScreen()));

    expect(find.text('YomiNow'), findsOneWidget);
    expect(find.text('Read Japanese Instantly'), findsOneWidget);
    expect(find.text('Licenses & Attribution'), findsOneWidget);
    expect(find.text('Third-party Libraries'), findsOneWidget);
    expect(find.text('Open Source'), findsOneWidget);
  });
}
