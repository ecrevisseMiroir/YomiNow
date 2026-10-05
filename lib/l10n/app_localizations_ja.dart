// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get homeScreenTitleTakePhoto => '写真を撮る';

  @override
  String get homeScreenTitleChooseFromGallery => 'ギャラリーから選択';

  @override
  String get homeScreenTitleOpenImage => '画像を開く';

  @override
  String get homeScreenRecentScans => '最近のスキャン';

  @override
  String get homeScreenSeeAll => 'すべて見る';

  @override
  String get homeScreenNoRecentScans => '最近のスキャンがここに表示されます。';

  @override
  String get homeScreenGreeting => 'こんにちは!';

  @override
  String get homeScreenSubtitle => '日本語のテキストにカメラを向け、\n任意の単語をタップするとすぐに読めます。';

  @override
  String get homeScreenSettingsTooltip => '設定';

  @override
  String get homeScreenNotificationsTooltip => '通知';

  @override
  String get homeScreenNoNotifications => '新しい通知はありません';

  @override
  String get homeScreenTitle => 'ホーム';

  @override
  String get documentsScreenTitle => 'ドキュメント';

  @override
  String get documentsScreenTabAll => 'すべて';

  @override
  String get documentsScreenTabImages => '画像';

  @override
  String get documentsScreenTabText => 'テキスト';

  @override
  String get documentsScreenEmptyTitle => 'まだドキュメントがありません';

  @override
  String get documentsScreenEmptySubtitle =>
      '最初の画像をスキャンするか、既存の画像をインポートして開始してください。';

  @override
  String get documentsScreenNoTextDocuments => 'テキストを認識したスキャン画像はまだありません。';

  @override
  String get documentsScreenCameraButton => 'カメラでスキャン';

  @override
  String get documentsScreenGalleryButton => 'ギャラリーから選択';

  @override
  String get documentsScreenPopupOpen => '開く';

  @override
  String get documentsScreenPopupDelete => '削除';

  @override
  String get cameraScannerFlashUnavailable => 'このカメラではフラッシュは利用できません。';

  @override
  String get cameraScannerCaptureFailed => '写真を撮れませんでした。もう一度試してください。';

  @override
  String get cameraScannerOpenGalleryFailed => 'フォトギャラリーを開けませんでした。';

  @override
  String get cameraScannerCloseCamera => 'カメラを閉じる';

  @override
  String get cameraScannerTurnFlashOff => 'フラッシュをオフにする';

  @override
  String get cameraScannerTurnFlashOn => 'フラッシュをオンにする';

  @override
  String get cameraScannerCameraUnavailable => 'カメラが利用できません';

  @override
  String get cameraScannerAccessInstructions => '設定でカメラへのアクセスを許可し、もう一度試してください。';

  @override
  String get cameraScannerTryAgain => '再試行';

  @override
  String get cameraScannerModePhoto => '写真';

  @override
  String get cameraScannerModeGallery => 'ギャラリー';

  @override
  String get cameraScannerChooseFromGallery => 'ギャラリーから選択';

  @override
  String get cameraScannerTakePhoto => '写真を撮る';

  @override
  String get cameraScannerSwitchCamera => 'カメラを切り替える';

  @override
  String get settingsScreenOCRTitle => 'OCR 設定';

  @override
  String get settingsScreenOCRSubtitle => 'Tesseract / ML Kit';

  @override
  String get settingsScreenBetaComingSoon => 'ベータ版 • 近日公開';

  @override
  String get settingsScreenFeatureComingSoon => 'この設定はベータ版で、近日公開予定です。';

  @override
  String get settingsScreenDictionaryTitle => '辞書';

  @override
  String get settingsScreenDictionarySubtitle => 'JMdict（オフライン）';

  @override
  String get settingsScreenAppearanceTitle => '外観';

  @override
  String get settingsScreenThemeSystem => 'システム';

  @override
  String get settingsScreenThemeLight => 'ライト';

  @override
  String get settingsScreenThemeDark => 'ダーク';

  @override
  String get settingsScreenLanguageTitle => '言語';

  @override
  String get settingsScreenAboutTitle => '概要';

  @override
  String get settingsScreenVersionLabel => 'バージョン';

  @override
  String get settingsScreenTitle => '設定';

  @override
  String get settingsScreenChooseLanguage => '言語を選択';

  @override
  String get imageScreenBackButtonTooltip => '戻る';

  @override
  String get imageScreenDetectedTextTitle => '検出されたテキスト';

  @override
  String get imageScreenModeText => 'テキスト';

  @override
  String get imageScreenModeImage => '画像';

  @override
  String get imageScreenLookupHint => '単語をタップして意味を見る';

  @override
  String get imageScreenNoJapaneseDetected => '日本語のテキストが検出されませんでした。';

  @override
  String get splashScreenLoading => '読み込み中...';

  @override
  String get splashScreenLogoSemantic => 'YomiNow ロゴ';

  @override
  String get splashScreenWordmarkSemantic => 'YomiNow、瞬時に日本語を読む';

  @override
  String get splashScreenBackgroundSemantic => '富士山と鳥居';

  @override
  String get aboutScreenTitle => '概要';

  @override
  String get aboutScreenSubtitle => '日本語をすぐに読む';

  @override
  String get aboutScreenDescription => 'オフラインの日本語OCRと辞書アプリ\nFlutterで作成';

  @override
  String get aboutScreenLicenses => 'ライセンスと帰属';

  @override
  String get aboutScreenThirdPartyLibraries => 'サードパーティライブラリ';

  @override
  String get aboutScreenOpenSource => 'オープンソース';

  @override
  String get appName => 'YomiNow';

  @override
  String get licensesScreenTitle => 'ライセンスと帰属';

  @override
  String get licensesScreenBackTooltip => '戻る';

  @override
  String get licensesScreenProjectCredits => 'プロジェクト クレジット';

  @override
  String get licensesScreenProjectDescription =>
      'このアプリは、オープンソースのOCR、辞書データ、モバイル ツールを組み合わせ、日本語テキストを瞬時に読めるようにしています。';

  @override
  String get licensesScreenAppLabel => 'アプリ';

  @override
  String get licensesScreenAppValue => 'YomiNow';

  @override
  String get licensesScreenLicenseStatusLabel => 'ライセンス状態';

  @override
  String get licensesScreenLicenseStatusValue => '最終的なプロジェクト ライセンスはまだ設定中です。';

  @override
  String get licensesScreenAttributionLabel => '帰属';

  @override
  String get licensesScreenAttributionValue =>
      'JMdict、IPADIC、Tesseract、Google ML Kit を以下に記載します。';

  @override
  String get licensesScreenDataSourcesTitle => 'データ ソース';

  @override
  String get licensesScreenDataSourcesBody =>
      'JMdictは日本語辞書検索に使用；IPADICはトークナイザーを駆動；TesseractとGoogle ML KitはOCRを駆動。';

  @override
  String get thirdPartyLibrariesScreenTitle => 'サードパーティライブラリ';

  @override
  String get thirdPartyLibrariesScreenBackTooltip => '戻る';

  @override
  String get thirdPartyLibrariesScreenFlutter => 'Flutter';

  @override
  String get thirdPartyLibrariesScreenFlutterPurpose =>
      'クロスプラットフォーム アプリ フレームワークと UI ツールキット。';

  @override
  String get thirdPartyLibrariesScreenCamera => 'camera';

  @override
  String get thirdPartyLibrariesScreenCameraPurpose =>
      'Android と iOS でのカスタム モバイル カメラ撮影フロー。';

  @override
  String get thirdPartyLibrariesScreenGoogleMlkit =>
      'google_mlkit_text_recognition';

  @override
  String get thirdPartyLibrariesScreenGoogleMlkitPurpose =>
      'モバイル スキャン用の日本語 OCR バックエンド。';

  @override
  String get thirdPartyLibrariesScreenImagePicker => 'image_picker';

  @override
  String get thirdPartyLibrariesScreenImagePickerPurpose =>
      'ギャラリーとカメラからの画像選択をサポート。';

  @override
  String get thirdPartyLibrariesScreenKuromoji => 'kuromoji';

  @override
  String get thirdPartyLibrariesScreenKuromojiPurpose => '日本語形態素解析と単語分析。';

  @override
  String get thirdPartyLibrariesScreenSqlite3 => 'sqlite3';

  @override
  String get thirdPartyLibrariesScreenSqlite3Purpose => 'オフライン辞書データベース アクセス。';

  @override
  String get thirdPartyLibrariesScreenPathProvider => 'path_provider';

  @override
  String get thirdPartyLibrariesScreenPathProviderPurpose =>
      'アプリデータとローカル アセットのファイルシステム アクセス。';

  @override
  String get thirdPartyLibrariesScreenImage => 'image';

  @override
  String get thirdPartyLibrariesScreenImagePurpose => '画像前処理と EXIF 向きの処理。';

  @override
  String get openSourceScreenTitle => 'オープンソース';

  @override
  String get openSourceScreenBackTooltip => '戻る';

  @override
  String get openSourceScreenDescription =>
      'YomiNowは、オープンでモジュール化され、共に改善しやすいよう構築されています。';

  @override
  String get openSourceScreenItem1Title => 'プロジェクト ソース';

  @override
  String get openSourceScreenItem1Detail =>
      'アプリのコードはプロジェクト ワークスペースに保持され、機能、サービス、UI 画面ごとに整理されています。';

  @override
  String get openSourceScreenItem2Title => '貢献モデル';

  @override
  String get openSourceScreenItem2Detail =>
      'OCR、辞書マッチング、UI の改善、アクセシビリティは、コア ワークフローを変更せずに改善できます。';

  @override
  String get openSourceScreenItem3Title => 'プロジェクトの考え方';

  @override
  String get openSourceScreenItem3Detail =>
      'YomiNowは、透明性があり、オフラインファーストで、将来の言語学習機能に簡単に拡張できるように設計されています。';

  @override
  String get imageScreenProcessingTitle => '画像を処理中...';

  @override
  String get imageScreenProcessingSubtitle => 'OCRを実行中';
  @override
  String get loadingStageImagePreprocessing => '画像前処理';
  @override
  String get loadingStageRunningOCR => 'OCR実行中';

  @override
  String get ankiNotificationAddedTitle => 'AnkiDroidに追加しました';

  @override
  String ankiNotificationAddedMessage(Object word) {
    return '「$word」をYomiNowデッキに追加しました。';
  }

  @override
  String get ankiNotificationOpenedTitle => 'AnkiDroidで完了してください';

  @override
  String ankiNotificationOpenedMessage(Object word) {
    return 'AnkiDroidで「$word」の追加を完了してください。';
  }

  @override
  String get ankiNotificationDuplicateTitle => 'AnkiDroidに登録済み';

  @override
  String ankiNotificationDuplicateMessage(Object word) {
    return '「$word」はYomiNowデッキにすでにあります。';
  }

  @override
  String get ankiAddAction => 'Ankiに追加';

  @override
  String get ankiAddChecking => '確認中...';

  @override
  String get ankiAddAlreadyAdded => 'Ankiに追加済み';

  @override
  String get ankiNotificationErrorTitle => 'カードを追加できませんでした';

  @override
  String get ankiNotificationErrorMessage =>
      'AnkiDroidがインストールされ、設定 > 詳細設定でAPI連携が有効になっていることを確認してください。';

  @override
  String get ankiNotificationRestartMessage =>
      'Android版AnkiDroid連携をインストールするため、YomiNowを再起動してください。';

  @override
  String get notificationHistoryEmpty => '新しい通知はありません';

  @override
  String get notificationHistoryClearAll => 'すべての通知を消去';

  @override
  String get notificationHistoryTitle => '通知履歴';

  @override
  String get notificationHistoryClearTooltip => '通知を消去';

  @override
  String get lookupNoWordMessage => 'ここに検索する語はありません。';

  @override
  String lookupNoEntryMessage(Object matchedText) {
    return '\"$matchedText\" の辞書エントリはありません';
  }

  @override
  String lookupFailedMessage(Object error) {
    return '検索に失敗しました：$error';
  }

  @override
  String get errorDialogTitle => '何かがうまくいきませんでした';

  @override
  String get errorDialogMessage => '画像を処理できませんでした。';

  @override
  String get errorDialogRetryPrompt => 'もう一度お試しください。';

  @override
  String get errorDialogRetryButton => 'リトライ';

  @override
  String get errorDialogGoBackButton => '戻る';

  @override
  String get noJapaneseTextTitle => '日本語のテキストが見つかりません';

  @override
  String get noJapaneseTextMessage => 'この画像で読み取れる日本語が見つかりませんでした。';

  @override
  String get noJapaneseTextSuggestion => 'テキストが写っている、もっと鮮明な写真を撮ってみてください。';

  @override
  String get noJapaneseTextButton => '別の画像を選択';

  @override
  String get lookupAttribution => '辞書データ: JMdict © EDRDG, CC BY‑SA 4.0';
}
