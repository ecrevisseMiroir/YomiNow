import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yominow/screens/documents_screen.dart';

import '../fakes.dart';

class ThrowingImagePicker extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    throw StateError('image processing failed');
  }
}

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

  testWidgets(
    'documents screen shows the error state when image processing fails',
    (tester) async {
      await tester.pumpWidget(
        withServices(
          fakeServices(),
          DocumentsScreen(picker: ThrowingImagePicker()),
        ),
      );

      await tester.ensureVisible(find.text('Scan with Camera'));
      await tester.tap(find.text('Scan with Camera'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text("We couldn't process the image."), findsOneWidget);
      expect(find.text('Please try again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Go back'), findsOneWidget);
    },
  );
}
