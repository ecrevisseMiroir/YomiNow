import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/app_services.dart';
import 'services/default_lookup_service.dart';
import 'services/image_preprocess.dart';
import 'services/kuromoji_tokenizer_service.dart';
import 'services/ocr/ocr_factory.dart';
import 'services/sqlite_dictionary_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenizer = KuromojiTokenizerService();
  final dictionary = SqliteDictionaryService();
  // Load the tokenizer and extract the dictionary in the background so the
  // first tap on a word is fast.
  unawaited(tokenizer.init());
  unawaited(dictionary.open());

  runApp(
    YomiNowApp(
      services: AppServices(
        ocr: createOcrService(),
        imagePreprocessor: DefaultImagePreprocessor(),
        tokenizer: tokenizer,
        lookup: DefaultLookupService(
          tokenizer: tokenizer,
          dictionary: dictionary,
        ),
      ),
    ),
  );
}
