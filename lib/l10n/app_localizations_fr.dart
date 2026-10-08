// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get homeScreenTitleTakePhoto => 'Prendre une photo';

  @override
  String get homeScreenTitleChooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get homeScreenTitleOpenImage => 'Ouvrir une image';

  @override
  String get homeScreenRecentScans => 'Scans récents';

  @override
  String get homeScreenRecentLookups => 'Recherches récentes';

  @override
  String get homeScreenNoRecentLookups => 'Aucune recherche récente.';

  @override
  String get homeScreenRecentLookupsButton => 'Recherches récentes';

  @override
  String get homeScreenSeeAll => 'Voir tout';

  @override
  String get homeScreenNoRecentScans => 'Vos scans récents apparaîtront ici.';

  @override
  String get homeScreenGreeting => 'Bienvenue !';

  @override
  String get homeScreenSubtitle =>
      'Pointez votre caméra sur du texte japonais,\ntapez n’importe quel mot, et lisez‑le immédiatement.';

  @override
  String get homeScreenSettingsTooltip => 'Paramètres';

  @override
  String get homeScreenNotificationsTooltip => 'Notifications';

  @override
  String get homeScreenNoNotifications => 'Pas de nouvelles notifications';

  @override
  String get homeScreenTitle => 'Accueil';

  @override
  String get documentsScreenTitle => 'Documents';

  @override
  String get documentsScreenTabAll => 'Tous';

  @override
  String get documentsScreenTabImages => 'Images';

  @override
  String get documentsScreenTabText => 'Texte';

  @override
  String get documentsScreenEmptyTitle => 'Pas de documents pour le moment';

  @override
  String get documentsScreenEmptySubtitle =>
      'Scannez votre première image ou importez‑en une existante pour commencer.';

  @override
  String get documentsScreenNoTextDocuments =>
      'Aucune image numérisée avec du texte reconnu pour le moment.';

  @override
  String get documentsScreenCameraButton => 'Scanner avec l\'appareil photo';

  @override
  String get documentsScreenGalleryButton => 'Choisir depuis la galerie';

  @override
  String get documentsScreenPopupOpen => 'Ouvrir';

  @override
  String get documentsScreenPopupDelete => 'Supprimer';

  @override
  String get cameraScannerFlashUnavailable =>
      'Le flash n\'est pas disponible sur cette caméra.';

  @override
  String get cameraScannerCaptureFailed =>
      'Impossible de capturer la photo. Réessayez.';

  @override
  String get cameraScannerOpenGalleryFailed =>
      'Impossible d\'ouvrir la galerie de photos.';

  @override
  String get cameraScannerCloseCamera => 'Fermer la caméra';

  @override
  String get cameraScannerTurnFlashOff => 'Désactiver le flash';

  @override
  String get cameraScannerTurnFlashOn => 'Activer le flash';

  @override
  String get cameraScannerCameraUnavailable => 'Caméra indisponible';

  @override
  String get cameraScannerAccessInstructions =>
      'Autorisez l\'accès à la caméra dans les paramètres, puis réessayez.';

  @override
  String get cameraScannerTryAgain => 'Réessayer';

  @override
  String get cameraScannerModePhoto => 'Photo';

  @override
  String get cameraScannerModeGallery => 'Galerie';

  @override
  String get cameraScannerChooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get cameraScannerTakePhoto => 'Prendre la photo';

  @override
  String get cameraScannerSwitchCamera => 'Changer de caméra';

  @override
  String get settingsScreenOCRTitle => 'Réglages OCR';

  @override
  String get settingsScreenOCRSubtitle => 'Tesseract / ML Kit';

  @override
  String get settingsScreenBetaComingSoon => 'Bêta • Bientôt disponible';

  @override
  String get settingsScreenFeatureComingSoon =>
      'Ce réglage est en bêta et sera bientôt disponible.';

  @override
  String get settingsScreenDictionaryTitle => 'Dictionnaire';

  @override
  String get settingsScreenDictionarySubtitle => 'JMdict (hors ligne)';

  @override
  String get settingsScreenAppearanceTitle => 'Apparence';

  @override
  String get settingsScreenThemeSystem => 'Système';

  @override
  String get settingsScreenThemeLight => 'Clair';

  @override
  String get settingsScreenThemeDark => 'Sombre';

  @override
  String get settingsScreenLanguageTitle => 'Langue';

  @override
  String get settingsScreenAboutTitle => 'À propos';

  @override
  String get settingsScreenVersionLabel => 'Version';

  @override
  String get settingsScreenTitle => 'Paramètres';

  @override
  String get settingsScreenChooseLanguage => 'Choisir la langue';

  @override
  String get imageScreenBackButtonTooltip => 'Retour';

  @override
  String get imageScreenDetectedTextTitle => 'Texte détecté';

  @override
  String get imageScreenModeText => 'Texte';

  @override
  String get imageScreenModeImage => 'Image';

  @override
  String get imageScreenLookupHint =>
      'Appuyez sur un mot pour voir sa signification';

  @override
  String get dialogClose => 'Fermer';

  @override
  String get dialogAddToAnki => 'Ajouter à Anki';

  @override
  String get dialogReadingLabel => 'Lecture :';

  @override
  String get dialogGlossLabel => 'Glossaire :';

  @override
  String ankiAddedMessage(String word) {
    return '« $word » ajouté à Anki';
  }

  @override
  String get imageScreenNoJapaneseDetected => 'Aucun texte japonais détecté.';

  @override
  String get splashScreenLoading => 'Chargement...';

  @override
  String get splashScreenLogoSemantic => 'logo YomiNow';

  @override
  String get splashScreenWordmarkSemantic =>
      'YomiNow, lire le japonais instantanément';

  @override
  String get splashScreenBackgroundSemantic => 'Mont Fuji et une porte torii';

  @override
  String get aboutScreenTitle => 'À propos';

  @override
  String get aboutScreenSubtitle => 'Lire le japonais instantanément';

  @override
  String get aboutScreenDescription =>
      'Une application OCR japonaise hors ligne et dictionnaire.';

  @override
  String get aboutScreenLicenses => 'Licences et attribution';

  @override
  String get aboutScreenThirdPartyLibraries => 'Bibliothèques tierces';

  @override
  String get aboutScreenOpenSource => 'Open Source';

  @override
  String get appName => 'YomiNow';

  @override
  String get licensesScreenTitle => 'Licences et attribution';

  @override
  String get licensesScreenBackTooltip => 'Retour';

  @override
  String get licensesScreenProjectCredits => 'Crédits du projet';

  @override
  String get licensesScreenProjectDescription =>
      'Cette application réunit OCR open source, données de dictionnaire et outils mobiles pour rendre le texte japonais instantanément lisible.';

  @override
  String get licensesScreenAppLabel => 'Application';

  @override
  String get licensesScreenAppValue => 'YomiNow';

  @override
  String get licensesScreenLicenseStatusLabel => 'Statut de la licence';

  @override
  String get licensesScreenLicenseStatusValue =>
      'La licence finale du projet est encore en cours de définition.';

  @override
  String get licensesScreenAttributionLabel => 'Attribution';

  @override
  String get licensesScreenAttributionValue =>
      'JMdict, IPADIC, Tesseract et Google ML Kit sont crédités ci-dessous.';

  @override
  String get licensesScreenDataSourcesTitle => 'Sources de données';

  @override
  String get licensesScreenDataSourcesBody =>
      'JMdict est utilisé pour la recherche dans le dictionnaire japonais ; IPADIC alimente le tokenizer ; Tesseract et Google ML Kit alimentent l\'OCR.';

  @override
  String get thirdPartyLibrariesScreenTitle => 'Bibliothèques tierces';

  @override
  String get thirdPartyLibrariesScreenBackTooltip => 'Retour';

  @override
  String get thirdPartyLibrariesScreenFlutter => 'Flutter';

  @override
  String get thirdPartyLibrariesScreenFlutterPurpose =>
      'Framework d\'application multiplateforme et boîte à outils UI.';

  @override
  String get thirdPartyLibrariesScreenCamera => 'camera';

  @override
  String get thirdPartyLibrariesScreenCameraPurpose =>
      'Flux de capture caméra mobile personnalisé sur Android et iOS.';

  @override
  String get thirdPartyLibrariesScreenGoogleMlkit =>
      'google_mlkit_text_recognition';

  @override
  String get thirdPartyLibrariesScreenGoogleMlkitPurpose =>
      'Backend OCR japonais pour le scan mobile.';

  @override
  String get thirdPartyLibrariesScreenImagePicker => 'image_picker';

  @override
  String get thirdPartyLibrariesScreenImagePickerPurpose =>
      'Sélection d\'images depuis la galerie et la caméra.';

  @override
  String get thirdPartyLibrariesScreenKuromoji => 'kuromoji';

  @override
  String get thirdPartyLibrariesScreenKuromojiPurpose =>
      'Tokenisation morphologique japonaise et analyse de mots.';

  @override
  String get thirdPartyLibrariesScreenSqlite3 => 'sqlite3';

  @override
  String get thirdPartyLibrariesScreenSqlite3Purpose =>
      'Accès à la base de données du dictionnaire hors ligne.';

  @override
  String get thirdPartyLibrariesScreenPathProvider => 'path_provider';

  @override
  String get thirdPartyLibrariesScreenPathProviderPurpose =>
      'Accès au système de fichiers pour les données de l\'application et les ressources locales.';

  @override
  String get thirdPartyLibrariesScreenImage => 'image';

  @override
  String get thirdPartyLibrariesScreenImagePurpose =>
      'Prétraitement d\'image et gestion de l\'orientation EXIF.';

  @override
  String get openSourceScreenTitle => 'Open Source';

  @override
  String get openSourceScreenBackTooltip => 'Retour';

  @override
  String get openSourceScreenDescription =>
      'YomiNow est conçu pour rester ouvert, modulaire et facile à améliorer ensemble.';

  @override
  String get openSourceScreenItem1Title => 'Source du projet';

  @override
  String get openSourceScreenItem1Detail =>
      'Le code de l\'application est conservé dans l\'espace de travail du projet et organisé par fonctionnalité, service et écran UI.';

  @override
  String get openSourceScreenItem2Title => 'Modèle de contribution';

  @override
  String get openSourceScreenItem2Detail =>
      'Des améliorations peuvent être apportées à l\'OCR, la correspondance du dictionnaire, le polissage de l\'UI et l\'accessibilité sans changer le flux principal.';

  @override
  String get openSourceScreenItem3Title => 'État d\'esprit du projet';

  @override
  String get openSourceScreenItem3Detail =>
      'YomiNow est conçu pour être transparent, hors-ligne d\'abord, et facile à étendre pour de futures fonctionnalités d\'apprentissage des langues.';

  @override
  String get imageScreenProcessingTitle => 'Traitement de l\'image...';

  @override
  String get imageScreenProcessingSubtitle => 'Exécution de l\'OCR';

  @override
  String get loadingStageImagePreprocessing => 'Préparation de l\'image...';

  @override
  String get loadingStageRunningOCR => 'Exécution de l\'OCR...';

  @override
  String get ankiNotificationAddedTitle => 'Ajouté à AnkiDroid';

  @override
  String ankiNotificationAddedMessage(Object word) {
    return '$word a été ajouté au paquet YomiNow.';
  }

  @override
  String get ankiNotificationOpenedTitle => 'Terminer dans AnkiDroid';

  @override
  String ankiNotificationOpenedMessage(Object word) {
    return 'Terminez l\'ajout de $word dans AnkiDroid.';
  }

  @override
  String get ankiNotificationDuplicateTitle => 'Déjà dans AnkiDroid';

  @override
  String ankiNotificationDuplicateMessage(Object word) {
    return '$word est déjà dans votre paquet YomiNow.';
  }

  @override
  String get ankiAddAction => 'Ajouter à Anki';

  @override
  String get ankiAddChecking => 'Vérification...';

  @override
  String get ankiAddAlreadyAdded => 'Déjà dans Anki';

  @override
  String get ankiNotificationErrorTitle => 'Impossible d\'ajouter la carte';

  @override
  String get ankiNotificationErrorMessage =>
      'Vérifiez qu\'AnkiDroid est installé et que l\'intégration API est activée dans Paramètres > Avancé.';

  @override
  String get ankiNotificationFailedTitle => 'Impossible d\'ajouter la carte';

  @override
  String get ankiNotificationFailedMessage =>
      'Échec de l\'ajout de la carte à AnkiDroid. Veuillez réessayer.';

  @override
  String get ankiNotificationRestartMessage =>
      'Redémarrez YomiNow pour installer l\'intégration AnkiDroid pour Android.';

  @override
  String get notificationHistoryEmpty => 'Tout est à jour';

  @override
  String get notificationHistoryClearAll => 'Effacer toutes les notifications';

  @override
  String get notificationHistoryTitle => 'Historique des notifications';

  @override
  String get notificationHistoryClearTooltip => 'Effacer les notifications';

  @override
  String get lookupNoWordMessage => 'Aucun mot à rechercher ici.';

  @override
  String lookupNoEntryMessage(Object matchedText) {
    return 'Aucune entrée de dictionnaire pour \"$matchedText\"';
  }

  @override
  String lookupFailedMessage(Object error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String get errorDialogTitle => 'Quelque chose s\'est mal passé';

  @override
  String get errorDialogMessage => 'Nous n\'avons pas pu traiter l\'image.';

  @override
  String get errorDialogRetryPrompt => 'Veuillez réessayer.';

  @override
  String get errorDialogRetryButton => 'Réessayer';

  @override
  String get errorDialogGoBackButton => 'Revenir';

  @override
  String get noJapaneseTextTitle => 'Aucun texte japonais trouvé';

  @override
  String get noJapaneseTextMessage =>
      'Nous n\'avons pas trouvé de texte japonais lisible dans cette image.';

  @override
  String get noJapaneseTextSuggestion =>
      'Essayez une photo plus nette avec le texte à l\'intérieur.';

  @override
  String get noJapaneseTextButton => 'Choisir une autre image';

  @override
  String get lookupAttribution =>
      'Données d\'attribution : JMdict © EDRDG, CC BY‑SA 4.0';

  @override
  String lookupHistoryAddedToAnki(Object word) {
    return '$word a été ajouté à Anki';
  }

  @override
  String lookupHistoryCopied(Object word) {
    return '$word copié';
  }

  @override
  String get lookupHistoryTitle => 'Recherches récentes';

  @override
  String get lookupHistoryTooltipAddedToAnki => 'Ajouté à Anki';

  @override
  String get lookupHistoryTooltipAddToAnki => 'Ajouter à Anki';

  @override
  String get lookupHistoryTooltipPronounce => 'Prononcer';

  @override
  String get lookupHistoryEmptyTitle => 'Aucune recherche pour le moment';

  @override
  String get lookupHistoryEmptySubtitle =>
      'Les mots que vous recherchez apparaîtront ici pour que vous puissiez les réviser ou les ajouter à Anki.';

  @override
  String get lookupHistoryJustNow => 'À l\'instant';

  @override
  String lookupHistoryMinutesAgo(Object count) {
    return 'il y a $count min';
  }

  @override
  String lookupHistoryHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'heures',
      one: 'heure',
    );
    return 'il y a $count $_temp0';
  }

  @override
  String lookupHistoryDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return 'il y a $count $_temp0';
  }
}
