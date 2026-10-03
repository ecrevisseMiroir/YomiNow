// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeScreenTitleTakePhoto => 'Take photo';

  @override
  String get homeScreenTitleChooseFromGallery => 'Choose from gallery';

  @override
  String get homeScreenTitleOpenImage => 'Open image';

  @override
  String get homeScreenRecentScans => 'Recent Scans';

  @override
  String get homeScreenSeeAll => 'See all';

  @override
  String get homeScreenGreeting => 'Welcome!';

  @override
  String get homeScreenSubtitle => 'Point your camera at Japanese text,\ntap any word, and read it now.';

  @override
  String get homeScreenSettingsTooltip => 'Settings';

  @override
  String get homeScreenNotificationsTooltip => 'Notifications';

  @override
  String get homeScreenNoNotifications => 'No new notifications';

  @override
  String get documentsScreenTitle => 'Documents';

  @override
  String get documentsScreenTabAll => 'All';

  @override
  String get documentsScreenTabImages => 'Images';

  @override
  String get documentsScreenTabText => 'Text';

  @override
  String get documentsScreenEmptyTitle => 'No Documents Yet';

  @override
  String get documentsScreenEmptySubtitle => 'Scan your first image or import an existing one to get started.';

  @override
  String get documentsScreenCameraButton => 'Scan with Camera';

  @override
  String get documentsScreenGalleryButton => 'Choose from Gallery';

  @override
  String get documentsScreenPopupOpen => 'Open';

  @override
  String get documentsScreenPopupDelete => 'Delete';

  @override
  String get cameraScannerFlashUnavailable => 'Flash is unavailable on this camera.';

  @override
  String get cameraScannerCaptureFailed => 'Could not capture the photo. Try again.';

  @override
  String get cameraScannerOpenGalleryFailed => 'Could not open the photo gallery.';

  @override
  String get cameraScannerCloseCamera => 'Close camera';

  @override
  String get cameraScannerTurnFlashOff => 'Turn flash off';

  @override
  String get cameraScannerTurnFlashOn => 'Turn flash on';

  @override
  String get cameraScannerCameraUnavailable => 'Camera unavailable';

  @override
  String get cameraScannerAccessInstructions => 'Allow camera access in Settings, then try again.';

  @override
  String get cameraScannerTryAgain => 'Try again';

  @override
  String get cameraScannerModePhoto => 'Photo';

  @override
  String get cameraScannerModeGallery => 'Gallery';

  @override
  String get cameraScannerChooseFromGallery => 'Choose from gallery';

  @override
  String get cameraScannerTakePhoto => 'Take photo';

  @override
  String get cameraScannerSwitchCamera => 'Switch camera';

  @override
  String get settingsScreenOCRTitle => 'OCR Settings';

  @override
  String get settingsScreenOCRSubtitle => 'Tesseract / ML Kit';

  @override
  String get settingsScreenDictionaryTitle => 'Dictionary';

  @override
  String get settingsScreenDictionarySubtitle => 'JMdict (offline)';

  @override
  String get settingsScreenAppearanceTitle => 'Appearance';

  @override
  String get settingsScreenAppearanceSubtitle => 'Light theme';

  @override
  String get settingsScreenLanguageTitle => 'Language';

  @override
  String get settingsScreenAboutTitle => 'About';

  @override
  String get settingsScreenVersionLabel => 'Version';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsScreenChooseLanguage => 'Choose language';

  @override
  String get imageScreenBackButtonTooltip => 'Back';

  @override
  String get imageScreenDetectedTextTitle => 'Detected Text';

  @override
  String get imageScreenModeText => 'Text';

  @override
  String get imageScreenModeImage => 'Image';

  @override
  String get imageScreenLookupHint => 'Tap a word to see its meaning';

  @override
  String get imageScreenNoJapaneseDetected => 'No Japanese text detected.';

  @override
  String get splashScreenLoading => 'Loading...';

  @override
  String get splashScreenLogoSemantic => 'YomiNow logo';

  @override
  String get splashScreenWordmarkSemantic => 'YomiNow, Read Japanese Instantly';

  @override
  String get splashScreenBackgroundSemantic => 'Mount Fuji and a torii gate';

  @override
  String get aboutScreenTitle => 'About';

  @override
  String get aboutScreenSubtitle => 'Read Japanese Instantly';

  @override
  String get aboutScreenDescription => 'An offline Japanese OCR and dictionary\napp built with Flutter.';

  @override
  String get aboutScreenLicenses => 'Licenses & Attribution';

  @override
  String get aboutScreenThirdPartyLibraries => 'Third-party Libraries';

  @override
  String get aboutScreenOpenSource => 'Open Source';

  @override
  String get appName => 'YomiNow';

  @override
  String get licensesScreenTitle => 'Licenses & Attribution';

  @override
  String get licensesScreenBackTooltip => 'Back';

  @override
  String get licensesScreenProjectCredits => 'Project credits';

  @override
  String get licensesScreenProjectDescription => 'This app brings together open-source OCR, dictionary data, and mobile tooling to make Japanese text instantly readable.';

  @override
  String get licensesScreenAppLabel => 'App';

  @override
  String get licensesScreenAppValue => 'YomiNow';

  @override
  String get licensesScreenLicenseStatusLabel => 'License status';

  @override
  String get licensesScreenLicenseStatusValue => 'Final project license is still being set.';

  @override
  String get licensesScreenAttributionLabel => 'Attribution';

  @override
  String get licensesScreenAttributionValue => 'JMdict, IPADIC, Tesseract, and Google ML Kit are credited below.';

  @override
  String get licensesScreenDataSourcesTitle => 'Data sources';

  @override
  String get licensesScreenDataSourcesBody => 'JMdict is used for Japanese dictionary lookup; IPADIC powers the tokenizer; Tesseract and Google ML Kit power OCR.';

  @override
  String get thirdPartyLibrariesScreenTitle => 'Third-party Libraries';

  @override
  String get thirdPartyLibrariesScreenBackTooltip => 'Back';

  @override
  String get thirdPartyLibrariesScreenFlutter => 'Flutter';

  @override
  String get thirdPartyLibrariesScreenFlutterPurpose => 'Cross-platform app framework and UI toolkit.';

  @override
  String get thirdPartyLibrariesScreenCamera => 'camera';

  @override
  String get thirdPartyLibrariesScreenCameraPurpose => 'Custom mobile camera capture flow on Android and iOS.';

  @override
  String get thirdPartyLibrariesScreenGoogleMlkit => 'google_mlkit_text_recognition';

  @override
  String get thirdPartyLibrariesScreenGoogleMlkitPurpose => 'Japanese OCR backend for mobile scanning.';

  @override
  String get thirdPartyLibrariesScreenImagePicker => 'image_picker';

  @override
  String get thirdPartyLibrariesScreenImagePickerPurpose => 'Gallery and camera image selection support.';

  @override
  String get thirdPartyLibrariesScreenKuromoji => 'kuromoji';

  @override
  String get thirdPartyLibrariesScreenKuromojiPurpose => 'Japanese morphological tokenization and word analysis.';

  @override
  String get thirdPartyLibrariesScreenSqlite3 => 'sqlite3';

  @override
  String get thirdPartyLibrariesScreenSqlite3Purpose => 'Offline dictionary database access.';

  @override
  String get thirdPartyLibrariesScreenPathProvider => 'path_provider';

  @override
  String get thirdPartyLibrariesScreenPathProviderPurpose => 'Filesystem access for app data and local assets.';

  @override
  String get thirdPartyLibrariesScreenImage => 'image';

  @override
  String get thirdPartyLibrariesScreenImagePurpose => 'Image preprocessing and EXIF orientation handling.';

  @override
  String get openSourceScreenTitle => 'Open Source';

  @override
  String get openSourceScreenBackTooltip => 'Back';

  @override
  String get openSourceScreenDescription => 'YomiNow is built to stay open, modular, and easy to improve together.';

  @override
  String get openSourceScreenItem1Title => 'Project source';

  @override
  String get openSourceScreenItem1Detail => 'The app code is kept in the project workspace and organized by feature, service, and UI screen.';

  @override
  String get openSourceScreenItem2Title => 'Contribution model';

  @override
  String get openSourceScreenItem2Detail => 'Improvements can be made to OCR, dictionary matching, UI polish, and accessibility without changing the core workflow.';

  @override
  String get openSourceScreenItem3Title => 'Project mindset';

  @override
  String get openSourceScreenItem3Detail => 'YomiNow is designed to be transparent, offline-first, and easy to extend for future language-learning features.';

  @override
  String get imageScreenProcessingTitle => 'Processing Image...';

  @override
  String get imageScreenProcessingSubtitle => 'Running OCR';
}
