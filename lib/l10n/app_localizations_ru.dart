// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Pixelka Offline';

  @override
  String get chatPageTitle => 'Pixelka offline';

  @override
  String get snackBarModelNotReady => 'Пикселька не готова или не выбрана.';

  @override
  String get snackBarSelectModel => 'Выбрать Пиксельку';

  @override
  String get appBarTooltipChangeModel => 'Сменить Пиксельку';

  @override
  String get chatHint => 'Спроси что-нибудь...';

  @override
  String get modelSelectionWelcome => 'Добро пожаловать!';

  @override
  String get modelSelectionPrompt =>
      'Пожалуйста, выберите Пиксельку для загрузки. Она будет скачана (один раз) и загружена в память.';

  @override
  String get batteryWarning =>
      'Оптимизация батареи может прервать загрузку. Нажмите \'Исправить\', чтобы разрешить приложению работать в фоне.';

  @override
  String get batteryWarningButton => 'Исправить';

  @override
  String get clearStorageDialogTitle => 'Удалить файлы Пискельки?';

  @override
  String get clearStorageDialogContent =>
      'Это действие удалит все скачанные файлы Пиксельки с вашего устройства, чтобы освободить место. Вы сможете скачать их снова в любое время.';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogDelete => 'Удалить';

  @override
  String get clearStorageButton => 'Очистить хранилище моделей';

  @override
  String statusInitializing(String modelName) {
    return 'Подготовка $modelName...';
  }

  @override
  String statusDownloading(String modelName, int progress) {
    return 'Скачивание $modelName: $progress%';
  }

  @override
  String statusRegistering(String modelName) {
    return 'Регистрация $modelName...';
  }

  @override
  String statusLoading(String modelName) {
    return 'Загрузка $modelName в память...';
  }

  @override
  String statusReady(String modelName) {
    return '$modelName готова! 🔥';
  }

  @override
  String statusError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get statusUnloading => 'Модель выгружена из памяти.';

  @override
  String get errorUnknown => 'Произошла неизвестная ошибка.';

  @override
  String get errorServiceNotInitialized =>
      '[ОШИБКА: Сервис не инициализирован]';

  @override
  String errorStreamFailed(String e) {
    return '[ОШИБКА: $e]';
  }

  @override
  String get modelNotSelected => 'Пикселька не выбрана.';

  @override
  String get chatClearHistory => 'Очистить историю?';

  @override
  String get chatClearHistoryContent =>
      'Это действие удалит все сообщения в этом чате. Это нельзя будет отменить.';

  @override
  String get chatClearHistoryButton => 'Очистить';

  @override
  String get copiedToClipboard => 'Скопировано!';

  @override
  String get myChatsTitle => 'Мои чаты';

  @override
  String get newChatButton => 'Новый чат';

  @override
  String get newChatTitle => 'Новый чат';

  @override
  String get loadingChat => 'Загрузка чата...';

  @override
  String get noChatsYet => 'Пока нет ни одного чата.';

  @override
  String get renameChatTitle => 'Переименовать чат';

  @override
  String get renameChatHint => 'Название чата';

  @override
  String get renameButton => 'Переименовать';

  @override
  String get deleteChatTitle => 'Удалить чат?';

  @override
  String deleteChatContent(String chatTitle) {
    return 'Вы уверены, что хотите удалить чат \'$chatTitle\'?';
  }

  @override
  String chatItemSubtitle(String date) {
    return 'Создан: $date';
  }
}
