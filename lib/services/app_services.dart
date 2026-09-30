import 'package:flutter/widgets.dart';

import 'image_preprocessor.dart';
import 'lookup_service.dart';
import 'ocr/ocr_service.dart';
import 'tokenizer_service.dart';

/// The services the UI depends on. Real implementations are wired in
/// `main.dart`; tests inject fakes.
class AppServices {
  const AppServices({
    required this.ocr,
    required this.imagePreprocessor,
    required this.tokenizer,
    required this.lookup,
  });

  final OcrService ocr;
  final ImagePreprocessor imagePreprocessor;
  final TokenizerService tokenizer;
  final LookupService lookup;
}

/// Makes [AppServices] available to the widget tree.
class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppServicesScope>();
    assert(scope != null, 'No AppServicesScope found in context');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) =>
      services != oldWidget.services;
}
