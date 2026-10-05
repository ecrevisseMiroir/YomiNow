import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
  ];

  /// No description provided for @homeScreenTitleTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get homeScreenTitleTakePhoto;

  /// No description provided for @homeScreenTitleChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get homeScreenTitleChooseFromGallery;

  /// No description provided for @homeScreenTitleOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Open image'**
  String get homeScreenTitleOpenImage;

  /// No description provided for @homeScreenRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get homeScreenRecentScans;

  /// No description provided for @homeScreenSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeScreenSeeAll;

  /// No description provided for @homeScreenNoRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Your recent scans will appear here.'**
  String get homeScreenNoRecentScans;

  /// No description provided for @homeScreenGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get homeScreenGreeting;

  /// No description provided for @homeScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at Japanese text,\ntap any word, and read it now.'**
  String get homeScreenSubtitle;

  /// No description provided for @homeScreenSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeScreenSettingsTooltip;

  /// No description provided for @homeScreenNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeScreenNotificationsTooltip;

  /// No description provided for @homeScreenNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get homeScreenNoNotifications;

  /// No description provided for @documentsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsScreenTitle;

  /// No description provided for @documentsScreenTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get documentsScreenTabAll;

  /// No description provided for @documentsScreenTabImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get documentsScreenTabImages;

  /// No description provided for @documentsScreenTabText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get documentsScreenTabText;

  /// No description provided for @documentsScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Documents Yet'**
  String get documentsScreenEmptyTitle;

  /// No description provided for @documentsScreenEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your first image or import an existing one to get started.'**
  String get documentsScreenEmptySubtitle;

  /// No description provided for @documentsScreenNoTextDocuments.
  ///
  /// In en, this message translates to:
  /// **'No scanned images with recognized text yet.'**
  String get documentsScreenNoTextDocuments;

  /// No description provided for @documentsScreenCameraButton.
  ///
  /// In en, this message translates to:
  /// **'Scan with Camera'**
  String get documentsScreenCameraButton;

  /// No description provided for @documentsScreenGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get documentsScreenGalleryButton;

  /// No description provided for @documentsScreenPopupOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get documentsScreenPopupOpen;

  /// No description provided for @documentsScreenPopupDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get documentsScreenPopupDelete;

  /// No description provided for @cameraScannerFlashUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Flash is unavailable on this camera.'**
  String get cameraScannerFlashUnavailable;

  /// No description provided for @cameraScannerCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not capture the photo. Try again.'**
  String get cameraScannerCaptureFailed;

  /// No description provided for @cameraScannerOpenGalleryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo gallery.'**
  String get cameraScannerOpenGalleryFailed;

  /// No description provided for @cameraScannerCloseCamera.
  ///
  /// In en, this message translates to:
  /// **'Close camera'**
  String get cameraScannerCloseCamera;

  /// No description provided for @cameraScannerTurnFlashOff.
  ///
  /// In en, this message translates to:
  /// **'Turn flash off'**
  String get cameraScannerTurnFlashOff;

  /// No description provided for @cameraScannerTurnFlashOn.
  ///
  /// In en, this message translates to:
  /// **'Turn flash on'**
  String get cameraScannerTurnFlashOn;

  /// No description provided for @cameraScannerCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraScannerCameraUnavailable;

  /// No description provided for @cameraScannerAccessInstructions.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in Settings, then try again.'**
  String get cameraScannerAccessInstructions;

  /// No description provided for @cameraScannerTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get cameraScannerTryAgain;

  /// No description provided for @cameraScannerModePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get cameraScannerModePhoto;

  /// No description provided for @cameraScannerModeGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get cameraScannerModeGallery;

  /// No description provided for @cameraScannerChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get cameraScannerChooseFromGallery;

  /// No description provided for @cameraScannerTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get cameraScannerTakePhoto;

  /// No description provided for @cameraScannerSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get cameraScannerSwitchCamera;

  /// No description provided for @settingsScreenOCRTitle.
  ///
  /// In en, this message translates to:
  /// **'OCR Settings'**
  String get settingsScreenOCRTitle;

  /// No description provided for @settingsScreenOCRSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tesseract / ML Kit'**
  String get settingsScreenOCRSubtitle;

  /// No description provided for @settingsScreenDictionaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get settingsScreenDictionaryTitle;

  /// No description provided for @settingsScreenDictionarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'JMdict (offline)'**
  String get settingsScreenDictionarySubtitle;

  /// No description provided for @settingsScreenAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsScreenAppearanceTitle;

  /// No description provided for @settingsScreenThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsScreenThemeSystem;

  /// No description provided for @settingsScreenThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsScreenThemeLight;

  /// No description provided for @settingsScreenThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsScreenThemeDark;

  /// No description provided for @settingsScreenLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsScreenLanguageTitle;

  /// No description provided for @settingsScreenAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsScreenAboutTitle;

  /// No description provided for @settingsScreenVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsScreenVersionLabel;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsScreenChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsScreenChooseLanguage;

  /// No description provided for @imageScreenBackButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get imageScreenBackButtonTooltip;

  /// No description provided for @imageScreenDetectedTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Detected Text'**
  String get imageScreenDetectedTextTitle;

  /// No description provided for @imageScreenModeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get imageScreenModeText;

  /// No description provided for @imageScreenModeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageScreenModeImage;

  /// No description provided for @imageScreenLookupHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a word to see its meaning'**
  String get imageScreenLookupHint;

  /// No description provided for @imageScreenNoJapaneseDetected.
  ///
  /// In en, this message translates to:
  /// **'No Japanese text detected.'**
  String get imageScreenNoJapaneseDetected;

  /// No description provided for @splashScreenLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashScreenLoading;

  /// No description provided for @splashScreenLogoSemantic.
  ///
  /// In en, this message translates to:
  /// **'YomiNow logo'**
  String get splashScreenLogoSemantic;

  /// No description provided for @splashScreenWordmarkSemantic.
  ///
  /// In en, this message translates to:
  /// **'YomiNow, Read Japanese Instantly'**
  String get splashScreenWordmarkSemantic;

  /// No description provided for @splashScreenBackgroundSemantic.
  ///
  /// In en, this message translates to:
  /// **'Mount Fuji and a torii gate'**
  String get splashScreenBackgroundSemantic;

  /// No description provided for @aboutScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutScreenTitle;

  /// No description provided for @aboutScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read Japanese Instantly'**
  String get aboutScreenSubtitle;

  /// No description provided for @aboutScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'An offline Japanese OCR and dictionary\napp built with Flutter.'**
  String get aboutScreenDescription;

  /// No description provided for @aboutScreenLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses & Attribution'**
  String get aboutScreenLicenses;

  /// No description provided for @aboutScreenThirdPartyLibraries.
  ///
  /// In en, this message translates to:
  /// **'Third-party Libraries'**
  String get aboutScreenThirdPartyLibraries;

  /// No description provided for @aboutScreenOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get aboutScreenOpenSource;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'YomiNow'**
  String get appName;

  /// No description provided for @licensesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Licenses & Attribution'**
  String get licensesScreenTitle;

  /// No description provided for @licensesScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get licensesScreenBackTooltip;

  /// No description provided for @licensesScreenProjectCredits.
  ///
  /// In en, this message translates to:
  /// **'Project credits'**
  String get licensesScreenProjectCredits;

  /// No description provided for @licensesScreenProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'This app brings together open-source OCR, dictionary data, and mobile tooling to make Japanese text instantly readable.'**
  String get licensesScreenProjectDescription;

  /// No description provided for @licensesScreenAppLabel.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get licensesScreenAppLabel;

  /// No description provided for @licensesScreenAppValue.
  ///
  /// In en, this message translates to:
  /// **'YomiNow'**
  String get licensesScreenAppValue;

  /// No description provided for @licensesScreenLicenseStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'License status'**
  String get licensesScreenLicenseStatusLabel;

  /// No description provided for @licensesScreenLicenseStatusValue.
  ///
  /// In en, this message translates to:
  /// **'Final project license is still being set.'**
  String get licensesScreenLicenseStatusValue;

  /// No description provided for @licensesScreenAttributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get licensesScreenAttributionLabel;

  /// No description provided for @licensesScreenAttributionValue.
  ///
  /// In en, this message translates to:
  /// **'JMdict, IPADIC, Tesseract, and Google ML Kit are credited below.'**
  String get licensesScreenAttributionValue;

  /// No description provided for @licensesScreenDataSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get licensesScreenDataSourcesTitle;

  /// No description provided for @licensesScreenDataSourcesBody.
  ///
  /// In en, this message translates to:
  /// **'JMdict is used for Japanese dictionary lookup; IPADIC powers the tokenizer; Tesseract and Google ML Kit power OCR.'**
  String get licensesScreenDataSourcesBody;

  /// No description provided for @thirdPartyLibrariesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party Libraries'**
  String get thirdPartyLibrariesScreenTitle;

  /// No description provided for @thirdPartyLibrariesScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get thirdPartyLibrariesScreenBackTooltip;

  /// No description provided for @thirdPartyLibrariesScreenFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get thirdPartyLibrariesScreenFlutter;

  /// No description provided for @thirdPartyLibrariesScreenFlutterPurpose.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform app framework and UI toolkit.'**
  String get thirdPartyLibrariesScreenFlutterPurpose;

  /// No description provided for @thirdPartyLibrariesScreenCamera.
  ///
  /// In en, this message translates to:
  /// **'camera'**
  String get thirdPartyLibrariesScreenCamera;

  /// No description provided for @thirdPartyLibrariesScreenCameraPurpose.
  ///
  /// In en, this message translates to:
  /// **'Custom mobile camera capture flow on Android and iOS.'**
  String get thirdPartyLibrariesScreenCameraPurpose;

  /// No description provided for @thirdPartyLibrariesScreenGoogleMlkit.
  ///
  /// In en, this message translates to:
  /// **'google_mlkit_text_recognition'**
  String get thirdPartyLibrariesScreenGoogleMlkit;

  /// No description provided for @thirdPartyLibrariesScreenGoogleMlkitPurpose.
  ///
  /// In en, this message translates to:
  /// **'Japanese OCR backend for mobile scanning.'**
  String get thirdPartyLibrariesScreenGoogleMlkitPurpose;

  /// No description provided for @thirdPartyLibrariesScreenImagePicker.
  ///
  /// In en, this message translates to:
  /// **'image_picker'**
  String get thirdPartyLibrariesScreenImagePicker;

  /// No description provided for @thirdPartyLibrariesScreenImagePickerPurpose.
  ///
  /// In en, this message translates to:
  /// **'Gallery and camera image selection support.'**
  String get thirdPartyLibrariesScreenImagePickerPurpose;

  /// No description provided for @thirdPartyLibrariesScreenKuromoji.
  ///
  /// In en, this message translates to:
  /// **'kuromoji'**
  String get thirdPartyLibrariesScreenKuromoji;

  /// No description provided for @thirdPartyLibrariesScreenKuromojiPurpose.
  ///
  /// In en, this message translates to:
  /// **'Japanese morphological tokenization and word analysis.'**
  String get thirdPartyLibrariesScreenKuromojiPurpose;

  /// No description provided for @thirdPartyLibrariesScreenSqlite3.
  ///
  /// In en, this message translates to:
  /// **'sqlite3'**
  String get thirdPartyLibrariesScreenSqlite3;

  /// No description provided for @thirdPartyLibrariesScreenSqlite3Purpose.
  ///
  /// In en, this message translates to:
  /// **'Offline dictionary database access.'**
  String get thirdPartyLibrariesScreenSqlite3Purpose;

  /// No description provided for @thirdPartyLibrariesScreenPathProvider.
  ///
  /// In en, this message translates to:
  /// **'path_provider'**
  String get thirdPartyLibrariesScreenPathProvider;

  /// No description provided for @thirdPartyLibrariesScreenPathProviderPurpose.
  ///
  /// In en, this message translates to:
  /// **'Filesystem access for app data and local assets.'**
  String get thirdPartyLibrariesScreenPathProviderPurpose;

  /// No description provided for @thirdPartyLibrariesScreenImage.
  ///
  /// In en, this message translates to:
  /// **'image'**
  String get thirdPartyLibrariesScreenImage;

  /// No description provided for @thirdPartyLibrariesScreenImagePurpose.
  ///
  /// In en, this message translates to:
  /// **'Image preprocessing and EXIF orientation handling.'**
  String get thirdPartyLibrariesScreenImagePurpose;

  /// No description provided for @openSourceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSourceScreenTitle;

  /// No description provided for @openSourceScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get openSourceScreenBackTooltip;

  /// No description provided for @openSourceScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'YomiNow is built to stay open, modular, and easy to improve together.'**
  String get openSourceScreenDescription;

  /// No description provided for @openSourceScreenItem1Title.
  ///
  /// In en, this message translates to:
  /// **'Project source'**
  String get openSourceScreenItem1Title;

  /// No description provided for @openSourceScreenItem1Detail.
  ///
  /// In en, this message translates to:
  /// **'The app code is kept in the project workspace and organized by feature, service, and UI screen.'**
  String get openSourceScreenItem1Detail;

  /// No description provided for @openSourceScreenItem2Title.
  ///
  /// In en, this message translates to:
  /// **'Contribution model'**
  String get openSourceScreenItem2Title;

  /// No description provided for @openSourceScreenItem2Detail.
  ///
  /// In en, this message translates to:
  /// **'Improvements can be made to OCR, dictionary matching, UI polish, and accessibility without changing the core workflow.'**
  String get openSourceScreenItem2Detail;

  /// No description provided for @openSourceScreenItem3Title.
  ///
  /// In en, this message translates to:
  /// **'Project mindset'**
  String get openSourceScreenItem3Title;

  /// No description provided for @openSourceScreenItem3Detail.
  ///
  /// In en, this message translates to:
  /// **'YomiNow is designed to be transparent, offline-first, and easy to extend for future language-learning features.'**
  String get openSourceScreenItem3Detail;

  /// No description provided for @imageScreenProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Image...'**
  String get imageScreenProcessingTitle;

  /// No description provided for @imageScreenProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Running OCR'**
  String get imageScreenProcessingSubtitle;

  /// No description provided for @ankiNotificationAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Added to AnkiDroid'**
  String get ankiNotificationAddedTitle;

  /// No description provided for @ankiNotificationAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{word} was added to the YomiNow deck.'**
  String ankiNotificationAddedMessage(Object word);

  /// No description provided for @ankiNotificationOpenedTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish in AnkiDroid'**
  String get ankiNotificationOpenedTitle;

  /// No description provided for @ankiNotificationOpenedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete adding {word} in AnkiDroid.'**
  String ankiNotificationOpenedMessage(Object word);

  /// No description provided for @ankiNotificationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not add card'**
  String get ankiNotificationErrorTitle;

  /// No description provided for @ankiNotificationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Check that AnkiDroid is installed and API Integration is enabled in Settings > Advanced.'**
  String get ankiNotificationErrorMessage;

  /// No description provided for @ankiNotificationRestartMessage.
  ///
  /// In en, this message translates to:
  /// **'Restart YomiNow to install the Android AnkiDroid integration.'**
  String get ankiNotificationRestartMessage;

  /// No description provided for @notificationHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationHistoryEmpty;

  /// No description provided for @notificationHistoryClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications'**
  String get notificationHistoryClearAll;

  /// No description provided for @notificationHistoryClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear notification history'**
  String get notificationHistoryClearTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
