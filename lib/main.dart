import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yominow/services/tts_service.dart';

import 'services/app_services.dart';
import 'services/app_appearance.dart';
import 'services/default_lookup_service.dart';
import 'services/document_repository.dart';
import 'services/image_preprocess.dart';
import 'services/kuromoji_tokenizer_service.dart';
import 'services/sqlite_dictionary_service.dart';
import 'services/ocr/ocr_factory.dart';
import 'app.dart';
import 'services/app_language.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenizer = KuromojiTokenizerService();
  final dictionary = SqliteDictionaryService();
  await TtsService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('selected_language');
  if (savedLang != null) {
    await AppLanguage.setLanguage(savedLang);
  }
  await AppAppearance.load();
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
        documents: SqliteDocumentRepository(),
      ),
    ),
  );
}
