import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('YomiNow Android UI', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver?.close();
      }
    });

    test('app launches and shows home screen', () async {
      await driver?.waitFor(find.byValueKey('home_screen'));
    });
  });
}
