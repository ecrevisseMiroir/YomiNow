import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yominow/models/ocr_result.dart';
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
  testWidgets('scanning opens OCR and keeps the document available to open', (
    tester,
  ) async {
    final picker = FakeImagePicker(XFile('photo.png'));
    final ocr = FakeOcrService();
    final services = fakeServices(ocr: ocr);

    await tester.pumpWidget(
      withServices(services, DocumentsScreen(picker: picker)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Documents Yet'), findsOneWidget);

    await tester.tap(find.text('Scan with Camera'));
    await tester.pumpAndSettle();

    expect(find.text('No Japanese text found'), findsOneWidget);
    expect(ocr.recognized, hasLength(1));

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('No Documents Yet'), findsNothing);
    expect(find.textContaining('photo.png'), findsOneWidget);

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    expect(
      find.text('No scanned images with recognized text yet.'),
      findsOneWidget,
    );
    expect(find.textContaining('photo.png'), findsNothing);

    await tester.tap(find.text('Images'));
    await tester.pumpAndSettle();
    expect(find.textContaining('photo.png'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('No Japanese text found'), findsOneWidget);
    expect(ocr.recognized, hasLength(2));
  });

  testWidgets('Text tab shows documents where OCR found text', (tester) async {
    final picker = FakeImagePicker(XFile('photo.png'));
    final ocr = FakeOcrService(
      result: const OcrResult(
        lines: [
          OcrLine(
            text: '日本語',
            words: [
              OcrWord(
                text: '日本語',
                bbox: Rect.fromLTWH(0, 0, 50, 20),
                start: 0,
                end: 3,
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      withServices(fakeServices(ocr: ocr), DocumentsScreen(picker: picker)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan with Camera'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();

    expect(find.textContaining('photo.png'), findsOneWidget);
    expect(
      find.text('No scanned images with recognized text yet.'),
      findsNothing,
    );
  });
}
