# YomiNow

[![Flutter CI](https://github.com/ecrevisseMiroir/YomiNow/workflows/Flutter%20CI/badge.svg)](https://github.com/ecrevisseMiroir/YomiNow/actions?query=workflow%3A%22Flutter+CI%22)
[![Deploy to GitHub Pages](https://github.com/ecrevisseMiroir/YomiNow/workflows/Deploy%20to%20GitHub%20Pages/badge.svg)](https://github.com/ecrevisseMiroir/YomiNow/actions?query=workflow%3A%22Deploy+to+GitHub+Pages%22)

Point your camera at Japanese text, tap a word, and read it now: OCR, tokenization and an offline JMdict lookup in one Flutter app.

YomiNow is a Flutter app for Linux desktop, Android and iOS. It started as a React/Vite web prototype, which is preserved on the branch `claude/yominow-architecture-planning-vk9xH`.

## Features

- Pick an image from the gallery or a file dialog, or take a photo (mobile).
- Normalizes the image before OCR: EXIF orientation is applied and the longest side is capped at 2000 px.
- Japanese OCR with tappable word boxes drawn over the image.
- Tap a word and the kuromoji (IPADIC) tokenizer finds it and its dictionary form.
- The dictionary form is looked up in a bundled JMdict SQLite database. A bottom sheet shows readings, part of speech and English glosses.
- A "Text" panel shows the full detected text with furigana. Each word in it is tappable too.
- Works offline: the OCR model and the dictionary ship with the app.

## Theme system

The app follows the device appearance setting and provides Material 3 light and
dark themes from `YomiNowTheme` in `lib/theme/yomi_now_theme.dart`. Use
`Theme.of(context).colorScheme` for semantic UI colors; use
`YomiNowPalette.coral`, `indigo`, `softBlue`, and `cream` for intentional brand
accents. Update the palette and theme builder there rather than adding new
brand color literals to screens.

## Platforms and OCR backends

| Platform                            | OCR backend                                         | Notes                                                                                                                                      |
| ----------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Linux (also macOS, Windows desktop) | Tesseract CLI                                       | `tesseract` must be installed. The Japanese LSTM model `jpn.traineddata` is bundled in `assets/tessdata` and passed with `--tessdata-dir`. |
| Android                             | Google ML Kit Text Recognition v2 (Japanese script) | Via `google_mlkit_text_recognition`.                                                                                                       |
| iOS                                 | Google ML Kit Text Recognition v2 (Japanese script) | Via `google_mlkit_text_recognition`.                                                                                                       |

Images come from `image_picker`: camera and gallery on mobile, a file dialog on desktop.

## Run it on Linux

1. Install Flutter (3.47.5 stable, Dart 3.13): <https://docs.flutter.dev/get-started/install/linux>
2. Install the build tools and Tesseract:

   ```sh
   sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev tesseract-ocr
   ```

3. Fetch the dependencies:

   ```sh
   flutter pub get
   ```

4. Run the app:

   ```sh
   flutter run -d linux
   ```

5. Run the tests. The unit and widget tests run headless. The end-to-end test
   builds the Linux app, OCRs `test/fixtures/ja_sample.png` with Tesseract,
   taps a word and checks the JMdict entry:

   ```sh
   flutter test
   flutter test integration_test -d linux   # prefix with `xvfb-run -a` on a headless machine
   ```

## Run it on Android

Connect a device or start an emulator, then:

```sh
flutter run
```

ML Kit's Japanese text recognition model is bundled through the Gradle dependency, so no download is needed at runtime.

### Install the APK without a computer

Every CI run uploads a release APK. It is signed with the debug key until a real signing config is added.

1. On your phone, open the repository's **Actions** tab, pick the latest green **Flutter CI** run, and download the `yominow-apk` artifact. You need to be signed in to GitHub.
2. Unzip it with the Files app and open `app-release.apk`.
3. When Android asks, allow your browser or Files app to install unknown apps.

## Run it on iOS

You need macOS, Xcode and CocoaPods. Then:

```sh
flutter run
```

The `pod install` step happens automatically.

## Dictionary

The lookup database is `assets/dict/jmdict.db.gz`, with its fingerprint in `assets/dict/jmdict.version`. On first run the app gunzips the database into the app-support directory and opens it with SQLite. On later launches it reads only the small version file and re-extracts when that changes.

The bundled file is currently built from the `jamdict-data` 1.5 PyPI package: full JMdict data from about 2020-05, with 191,541 entries (18 MB gzipped). The official source wasn't reachable from the build environment, so this is a stand-in.

To refresh it from the official EDRDG file:

```sh
flutter pub get
curl -LO https://www.edrdg.org/pub/Nihongo/JMdict_e.gz
dart run tool/build_jmdict.dart --jmdict-xml JMdict_e.gz
```

The first `dart run` downloads a prebuilt SQLite library for the `sqlite3` package, so it needs network access. Options:

- `--out assets/dict/jmdict.db.gz` sets the output path. The version file is written next to it.
- `--common-only` keeps only entries marked as common.
- `--jamdict-db <path>` builds from a jamdict SQLite database instead of the XML.

## Project layout

```text
lib/
  models/      OCR result, token, dictionary entry, lookup result
  theme/       brand palette and light/dark Material 3 themes
  services/
    ocr/       Tesseract and ML Kit backends, plus the factory that picks one
    image_preprocess.dart
    kuromoji_tokenizer_service.dart
    sqlite_dictionary_service.dart
    default_lookup_service.dart
    app_services.dart
  screens/     home, image
  widgets/     word overlay, lookup sheet, tokenized text
assets/
  tessdata/    jpn.traineddata for the Tesseract backend
  dict/        jmdict.db.gz, jmdict.version
tool/
  build_jmdict.dart   builds assets/dict/jmdict.db.gz
test/                 unit and widget tests, fixtures
integration_test/     end-to-end OCR → tap → dictionary test on the desktop app
.github/workflows/flutter.yml   CI: Linux analyze/test/e2e/build, Android APK, iOS (manual)
```

## Continuous integration

`.github/workflows/flutter.yml` runs on pushes to `main`, `dev`, `canary`, and `claude/**`, on pull requests, and on manual dispatch. The `linux` job runs `flutter analyze`, `flutter test`, the end-to-end test under Xvfb, and a release build. The `android` job builds a release APK and uploads it as the `yominow-apk` artifact. The `ios` job runs only when dispatched by hand, to save macOS minutes.

Release names use the app version from `pubspec.yaml` (`0.1.1` from `0.1.1+1`) with a channel suffix where needed:

- A push to `main` publishes `v0.1.1+<commit>` as a stable production release.
- A push to `dev` publishes `v0.1.1-dev.<commit>` as a prerelease.
- A push to `canary` publishes `v0.1.1-canary.<commit>` as a prerelease.
- A pushed version tag such as `v0.1.1` publishes that stable production version. It must match the version in `pubspec.yaml`, ignoring the build number.

## Contributing

Contributions are welcome! See [issue #6](https://github.com/ecrevisseMiroir/YomiNow/issues/6) for contribution guidelines and code of conduct. Here is a short guide on how to run the app locally and get started:

### Run it on Linux

1. Install Flutter (3.47.5 stable, Dart 3.13): <https://docs.flutter.dev/get-started/install/linux>
2. Install the build tools and Tesseract:

   ```sh
   sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev tesseract-ocr
   ```

3. Fetch the dependencies:

   ```sh
   flutter pub get
   ```

4. Run the app:

   ```sh
   flutter run -d linux
   ```

5. Run the tests. The unit and widget tests run headless. The end-to-end test
   builds the Linux app, OCRs `test/fixtures/ja_sample.png` with Tesseract,
   taps a word and checks the JMdict entry:

   ```sh
   flutter test
   flutter test integration_test -d linux   # prefix with `xvfb-run -a` on a headless machine
   ```

### Run it on Android

Connect a device or start an emulator, then:

```sh
flutter run
```

ML Kit's Japanese text recognition model is bundled through the Gradle dependency, so no download is needed at runtime.

### Install the APK without a computer

Every CI run uploads a release APK. It is signed with the debug key until a real signing config is added.

1. On your phone, open the repository's **Actions** tab, pick the latest green **Flutter CI** run, and download the `yominow-apk` artifact. You need to be signed in to GitHub.
2. Unzip it with the Files app and open `app-release.apk`.
3. When Android asks, allow your browser or Files app to install unknown apps.

### Run it on iOS

You need macOS, Xcode and CocoaPods. Then:

```sh
flutter run
```

The `pod install` step happens automatically.

## Licences and attribution

The licence for the YomiNow app code has not been decided yet. See [issue #7](https://github.com/ecrevisseMiroir/YomiNow/issues/7).

Third-party data and components:

- **JMdict** is the property of the Electronic Dictionary Research and Development Group (EDRDG) and is used under CC BY-SA 4.0. See <https://www.edrdg.org/edrdg/licence.html>.
- **IPADIC** is used through the [`kuromoji`](https://pub.dev/packages/kuromoji) Dart package, a Dart port of kuromoji.js.
- **Tesseract** is licensed under Apache-2.0, and so is the `jpn` tessdata model.
- **Google ML Kit** is used under Google's ML Kit terms.

## References

- J. Breen, "JMdict: a Japanese-Multilingual Dictionary", COLING Workshop on Multilingual Linguistic Resources, 2004.
- T. Kudo, K. Yamamoto, Y. Matsumoto, "Applying Conditional Random Fields to Japanese Morphological Analysis", EMNLP 2004. This is the basis of MeCab and its IPADIC tokenization.
- R. Smith, "An Overview of the Tesseract OCR Engine", ICDAR 2007.
