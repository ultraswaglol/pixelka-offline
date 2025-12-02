import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Pixelka Offline'**
  String get appTitle;

  /// No description provided for @chatPageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Pixelka offline'**
  String get chatPageTitle;

  /// No description provided for @snackBarModelNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Пикселька не готова или не выбрана.'**
  String get snackBarModelNotReady;

  /// No description provided for @snackBarSelectModel.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать Пиксельку'**
  String get snackBarSelectModel;

  /// No description provided for @appBarTooltipChangeModel.
  ///
  /// In ru, this message translates to:
  /// **'Сменить Пиксельку'**
  String get appBarTooltipChangeModel;

  /// No description provided for @chatHint.
  ///
  /// In ru, this message translates to:
  /// **'Спроси что-нибудь...'**
  String get chatHint;

  /// No description provided for @modelSelectionWelcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать!'**
  String get modelSelectionWelcome;

  /// No description provided for @modelSelectionPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, выберите Пиксельку для загрузки. Она будет скачана (один раз) и загружена в память.'**
  String get modelSelectionPrompt;

  /// No description provided for @batteryWarning.
  ///
  /// In ru, this message translates to:
  /// **'Оптимизация батареи может прервать загрузку. Нажмите \'Исправить\', чтобы разрешить приложению работать в фоне.'**
  String get batteryWarning;

  /// No description provided for @batteryWarningButton.
  ///
  /// In ru, this message translates to:
  /// **'Исправить'**
  String get batteryWarningButton;

  /// No description provided for @clearStorageDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить файлы Пискельки?'**
  String get clearStorageDialogTitle;

  /// No description provided for @clearStorageDialogContent.
  ///
  /// In ru, this message translates to:
  /// **'Это действие удалит все скачанные файлы Пиксельки с вашего устройства, чтобы освободить место. Вы сможете скачать их снова в любое время.'**
  String get clearStorageDialogContent;

  /// No description provided for @dialogCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get dialogCancel;

  /// No description provided for @dialogDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get dialogDelete;

  /// No description provided for @clearStorageButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить хранилище моделей'**
  String get clearStorageButton;

  /// No description provided for @statusInitializing.
  ///
  /// In ru, this message translates to:
  /// **'Подготовка {modelName}...'**
  String statusInitializing(String modelName);

  /// No description provided for @statusDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание {modelName}: {progress}%'**
  String statusDownloading(String modelName, int progress);

  /// No description provided for @statusRegistering.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация {modelName}...'**
  String statusRegistering(String modelName);

  /// No description provided for @statusLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка {modelName} в память...'**
  String statusLoading(String modelName);

  /// No description provided for @statusReady.
  ///
  /// In ru, this message translates to:
  /// **'{modelName} готова! 🔥'**
  String statusReady(String modelName);

  /// No description provided for @statusError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String statusError(String error);

  /// No description provided for @statusUnloading.
  ///
  /// In ru, this message translates to:
  /// **'Модель выгружена из памяти.'**
  String get statusUnloading;

  /// No description provided for @errorUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Произошла неизвестная ошибка.'**
  String get errorUnknown;

  /// No description provided for @errorServiceNotInitialized.
  ///
  /// In ru, this message translates to:
  /// **'[ОШИБКА: Сервис не инициализирован]'**
  String get errorServiceNotInitialized;

  /// No description provided for @errorStreamFailed.
  ///
  /// In ru, this message translates to:
  /// **'[ОШИБКА: {e}]'**
  String errorStreamFailed(String e);

  /// No description provided for @modelNotSelected.
  ///
  /// In ru, this message translates to:
  /// **'Пикселька не выбрана.'**
  String get modelNotSelected;

  /// No description provided for @chatClearHistory.
  ///
  /// In ru, this message translates to:
  /// **'Очистить историю?'**
  String get chatClearHistory;

  /// No description provided for @chatClearHistoryContent.
  ///
  /// In ru, this message translates to:
  /// **'Это действие удалит все сообщения в этом чате. Это нельзя будет отменить.'**
  String get chatClearHistoryContent;

  /// No description provided for @chatClearHistoryButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get chatClearHistoryButton;

  /// No description provided for @copiedToClipboard.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано!'**
  String get copiedToClipboard;

  /// No description provided for @myChatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои чаты'**
  String get myChatsTitle;

  /// No description provided for @newChatButton.
  ///
  /// In ru, this message translates to:
  /// **'Новый чат'**
  String get newChatButton;

  /// No description provided for @newChatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый чат'**
  String get newChatTitle;

  /// No description provided for @loadingChat.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка чата...'**
  String get loadingChat;

  /// No description provided for @noChatsYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет ни одного чата.'**
  String get noChatsYet;

  /// No description provided for @renameChatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать чат'**
  String get renameChatTitle;

  /// No description provided for @renameChatHint.
  ///
  /// In ru, this message translates to:
  /// **'Название чата'**
  String get renameChatHint;

  /// No description provided for @renameButton.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get renameButton;

  /// No description provided for @deleteChatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить чат?'**
  String get deleteChatTitle;

  /// No description provided for @deleteChatContent.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить чат \'{chatTitle}\'?'**
  String deleteChatContent(String chatTitle);

  /// No description provided for @chatItemSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создан: {date}'**
  String chatItemSubtitle(String date);
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
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
