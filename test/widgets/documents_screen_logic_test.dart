import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yominow/screens/documents_screen.dart';

import '../fakes.dart';

class FakeImagePicker extends ImagePicker {
  FakeImagePicker(this.file);

  final XFile file;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    return file;
  }
}

void main() {
  testWidgets('empty state switches to documents after scanning', (
    tester,
  ) async {
    final picker = FakeImagePicker(XFile('photo.png'));

    await tester.pumpWidget(
      withServices(fakeServices(), DocumentsScreen(picker: picker)),
    );

    expect(find.text('No Documents Yet'), findsOneWidget);

    await tester.tap(find.text('Scan with Camera'));
    await tester.pumpAndSettle();

    expect(find.text('No Documents Yet'), findsNothing);
    expect(find.textContaining('photo.png'), findsOneWidget);
  });
}
