import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'package:pixelka_offline/models/chat_message.dart';
import 'package:pixelka_offline/models/model_definition.dart';
import 'package:pixelka_offline/models/llm_status.dart';
import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/models/chat_meta_data.dart';
import 'package:pixelka_offline/config/app_config.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

class LlmService extends ChangeNotifier {
  final List<ModelDefinition> availableModels = [
    ModelDefinition(
      modelUrl:
          'https://storage.yandexcloud.net/pixelka-file-offline/pixelka-offline.task',
      modelFilename: 'pixelka-offline.task',
      displayName: 'Pixelka-offline',
    ),
  ];

  ModelDefinition? currentModel;

  // ✅ Безопасное получение токена
  final String _huggingFaceToken = AppConfig.hfToken;

  InferenceModel? _model;
  bool _isLoading = false;
  bool _isInitialized = false;

  LlmStatus _status = LlmStatus.uninitialized;
  int _progress = 0;
  String? _lastError;
  String? _batteryOptimizationWarningKey;

  final ReceivePort _port = ReceivePort();
  bool _isGenerationCancelled = false;
  final Box<ChatMetaData> _chatListBox = Hive.box<ChatMetaData>('chat_list');
  final Map<String, ModelDefinition> _activeDownloads = {};

  final _random = Random();

  final String _interstitialAdUnitId = AppConfig.interstitialAdId;
  InterstitialAdLoader? _interstitialAdLoader;

  final String _appOpenAdUnitId = AppConfig.appOpenAdId;
  AppOpenAdLoader? _appOpenAdLoader;
  AppOpenAd? _appOpenAd;

  LlmService() {
    _initAppOpenAdLoader();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) {
      final String id = data[0];
      final int status = data[1];
      final int progress = data[2];

      final modelForTask = _activeDownloads[id];

      if (modelForTask == null) {
        return;
      }

      if (status == DownloadTaskStatus.complete.index) {
        _loadModelFromDisk(modelForTask);
        _activeDownloads.remove(id);
        return;
      }

      if (status == DownloadTaskStatus.failed.index ||
          status == DownloadTaskStatus.canceled.index ||
          status == DownloadTaskStatus.undefined.index) {
        _isLoading = false;
        _lastError = "Ошибка скачивания. Статус: $status";
        _status = LlmStatus.error;
        _activeDownloads.remove(id);
        notifyListeners();
        return;
      }

      _progress = progress;
      if (_isLoading && _status == LlmStatus.downloading) {
        notifyListeners();
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  LlmStatus get status => _status;
  int get progress => _progress;
  String? get lastError => _lastError;
  String? get batteryOptimizationWarningKey => _batteryOptimizationWarningKey;

  Future<void> _initAppOpenAdLoader() async {
    if (_appOpenAdUnitId.isEmpty) {
      debugPrint("[ADS] App Open Ad ID не настроен в .env");
      return;
    }

    _appOpenAdLoader = await AppOpenAdLoader.create(
      onAdLoaded: (AppOpenAd ad) {
        debugPrint("[ADS] App Open Ad загружена успешно!");
        _appOpenAd = ad;
        _showAppOpenAdInternal();
      },
      onAdFailedToLoad: (error) {
        debugPrint("[ADS] Ошибка загрузки App Open Ad: ${error.description}");
      },
    );
  }

  void loadAndShowAppOpenAd() {
    if (_appOpenAdUnitId.isEmpty) return;

    if (_appOpenAdLoader == null) {
      debugPrint("[ADS] Загрузчик App Open Ad еще не готов, ждем...");
      _initAppOpenAdLoader().then((_) {
        _loadAppOpenAdActual();
      });
    } else {
      _loadAppOpenAdActual();
    }
  }

  void _loadAppOpenAdActual() {
    debugPrint("[ADS] Запрос на загрузку App Open Ad...");
    final configuration = AdRequestConfiguration(adUnitId: _appOpenAdUnitId);
    _appOpenAdLoader?.loadAd(adRequestConfiguration: configuration);
  }

  void _showAppOpenAdInternal() {
    if (_appOpenAd == null) return;

    _appOpenAd!.setAdEventListener(
      eventListener: AppOpenAdEventListener(
        onAdShown: () => debugPrint("[ADS] App Open Ad показана"),
        onAdDismissed: () {
          debugPrint("[ADS] App Open Ad закрыта пользователем");
          _appOpenAd = null;
        },
        onAdFailedToShow: (error) {
          debugPrint("[ADS] Ошибка показа App Open Ad: ${error.description}");
          _appOpenAd = null;
        },
      ),
    );

    _appOpenAd!.show();
  }

  Future<void> maybeShowInterstitialAd() async {
    if (_interstitialAdUnitId.isEmpty) {
      debugPrint("[ADS] Interstitial Ad ID не настроен в .env");
      return;
    }

    if (_random.nextInt(100) >= 99) {
      debugPrint("[ADS] Шанс не сработал. Реклама не будет показана.");
      return;
    }

    debugPrint("[ADS] Шанс сработал! Загружаем Interstitial Ad...");

    _interstitialAdLoader = await InterstitialAdLoader.create(
      onAdLoaded: (InterstitialAd ad) {
        debugPrint("[ADS] Interstitial Ad загружена. Показываем...");
        ad.show();
        ad.setAdEventListener(
          eventListener: InterstitialAdEventListener(
            onAdDismissed: () => debugPrint("[ADS] Interstitial Ad закрыта."),
            onAdFailedToShow: (error) => debugPrint(
                "[ADS] Ошибка показа Interstitial Ad: ${error.description}"),
          ),
        );
      },
      onAdFailedToLoad: (AdRequestError error) {
        debugPrint(
            "[ADS] Ошибка загрузки Interstitial Ad: ${error.description}");
      },
    );

    final adRequestConfiguration =
        AdRequestConfiguration(adUnitId: _interstitialAdUnitId);
    _interstitialAdLoader!
        .loadAd(adRequestConfiguration: adRequestConfiguration);
  }

  List<ChatMetaData> getChatList() {
    var chats = _chatListBox.values.toList();
    chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chats;
  }

  ChatMetaData? getChatMeta(String chatId) {
    return _chatListBox.get(chatId);
  }

  Future<ChatMetaData> createNewChat(String defaultTitle) async {
    final newId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
    final newChat = ChatMetaData(
      id: newId,
      title: defaultTitle,
      createdAt: DateTime.now(),
    );
    await _chatListBox.put(newChat.id, newChat);
    notifyListeners();
    return newChat;
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    final chat = _chatListBox.get(chatId);
    if (chat != null) {
      chat.title = newTitle;
      await chat.save();
      notifyListeners();
    }
  }

  Future<void> deleteChat(String chatId) async {
    await _chatListBox.delete(chatId);
    if (await Hive.boxExists(chatId)) {
      await Hive.deleteBoxFromDisk(chatId);
    }
    notifyListeners();
  }

  Future<Box<ChatMessage>> _getChatBox(String chatId) async {
    if (Hive.isBoxOpen(chatId)) {
      return Hive.box<ChatMessage>(chatId);
    }
    return await Hive.openBox<ChatMessage>(chatId);
  }

  Future<List<ChatMessage>> getMessages(String chatId) async {
    final box = await _getChatBox(chatId);
    return box.values.toList();
  }

  Future<void> addMessage(String chatId, ChatMessage message) async {
    final box = await _getChatBox(chatId);
    await box.add(message);
  }

  Future<void> clearHistory(String chatId) async {
    final box = await _getChatBox(chatId);
    await box.clear();
  }

  Future<void> _clearCacheDirectory() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      debugPrint("Ошибка при очистке кэша: $e");
    }
  }

  Future<void> unloadModel() async {
    await _clearCacheDirectory();
    _model?.close();
    _model = null;
    _isInitialized = false;
    _status = LlmStatus.unloading;
    currentModel = null;
    notifyListeners();
  }

  Future<void> clearDownloadedModels() async {
    if (_isLoading) return;
    _isLoading = true;
    _status = LlmStatus.unloading;
    notifyListeners();

    try {
      await _clearCacheDirectory();
      await unloadModel();
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory(appDir.path);
      final List<FileSystemEntity> entities = await dir.list().toList();

      for (final entity in entities) {
        final path = entity.path;
        if (path.endsWith('.task') || path.endsWith('.task.inactive')) {
          await entity.delete();
        }
      }
      _status = LlmStatus.uninitialized;
    } catch (e) {
      _lastError = e.toString();
      _status = LlmStatus.error;
    } finally {
      _isLoading = false;
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> _cleanupExistingTask(String filename) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE file_name = '$filename'");
    if (tasks == null) return;
    for (final task in tasks) {
      await FlutterDownloader.remove(
          taskId: task.taskId, shouldDeleteContent: true);
    }
  }

  Future<void> requestBatteryOptimizationBypass() async {
    await Permission.ignoreBatteryOptimizations.request();
    await _checkBatteryOptimization();
    if (_batteryOptimizationWarningKey == null && currentModel != null) {
      notifyListeners();
    }
  }

  Future<void> _checkBatteryOptimization() async {
    final isIgnored = await Permission.ignoreBatteryOptimizations.isGranted;
    if (!isIgnored) {
      _batteryOptimizationWarningKey = "batteryWarning";
    } else {
      _batteryOptimizationWarningKey = null;
    }
    notifyListeners();
  }

  Future<void> _loadModelFromDisk(ModelDefinition modelToLoad) async {
    _isLoading = true;
    _status = LlmStatus.registering;
    notifyListeners();

    try {
      await WakelockPlus.enable();
      final appDir = await getApplicationDocumentsDirectory();
      final activePath = p.join(appDir.path, modelToLoad.modelFilename);

      await FlutterGemma.installModel(modelType: modelToLoad.modelType)
          .fromFile(activePath)
          .install();

      _status = LlmStatus.loading;
      notifyListeners();

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 4096,
        preferredBackend: PreferredBackend.gpu,
      );

      _isInitialized = true;
      _status = LlmStatus.ready;
    } catch (e) {
      _isInitialized = false;
      _lastError = e.toString();
      _status = LlmStatus.error;
    } finally {
      _isLoading = false;
      await WakelockPlus.disable();
      notifyListeners();
    }
  }

  Future<void> _downloadModelInBackground(
      ModelDefinition modelToDownload) async {
    final notifStatus = await Permission.notification.request();
    if (notifStatus.isDenied || notifStatus.isPermanentlyDenied) {
      debugPrint("Разрешение на УВЕДОМЛЕНИЯ отклонено!");
    }

    await _checkBatteryOptimization();
    await _cleanupExistingTask(modelToDownload.modelFilename);

    final appDir = await getApplicationDocumentsDirectory();
    final savePath = appDir.path;

    final Map<String, String> headers = {};
    if (_huggingFaceToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_huggingFaceToken';
    }

    final taskId = await FlutterDownloader.enqueue(
      url: modelToDownload.modelUrl,
      headers: headers,
      savedDir: savePath,
      fileName: modelToDownload.modelFilename,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      _activeDownloads[taskId] = modelToDownload;
    } else {
      throw Exception("Не удалось запустить фоновую загрузку.");
    }
  }

  Future<void> initialize(ModelDefinition modelToLoad) async {
    if (_isLoading) return;
    await _clearCacheDirectory();

    _isLoading = true;
    _lastError = null;
    currentModel = modelToLoad;
    _status = LlmStatus.initializing;
    notifyListeners();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      for (final modelDef in availableModels) {
        if (modelDef.modelFilename != modelToLoad.modelFilename) {
          final activePath = p.join(appDir.path, modelDef.modelFilename);
          final inactivePath = '$activePath.inactive';
          final activeFile = File(activePath);
          if (await activeFile.exists()) {
            await activeFile.rename(inactivePath);
          }
        }
      }

      final activePath = p.join(appDir.path, modelToLoad.modelFilename);
      final inactiveFile = File('$activePath.inactive');
      final activeFile = File(activePath);

      bool isInstalled = await activeFile.exists();
      if (!isInstalled && await inactiveFile.exists()) {
        await inactiveFile.rename(activePath);
        isInstalled = true;
      }

      if (isInstalled) {
        await _loadModelFromDisk(modelToLoad);
      } else {
        _status = LlmStatus.downloading;
        _progress = 0;
        notifyListeners();
        await _downloadModelInBackground(modelToLoad);
      }
    } catch (e) {
      _isLoading = false;
      _isInitialized = false;
      _lastError = e.toString();
      _status = LlmStatus.error;
      notifyListeners();
    }
  }

  void cancelGeneration() {
    _isGenerationCancelled = true;
  }

  Stream<String> generateTextResponse(
      String text, AppLocalizations l10n, String chatId) async* {
    if (!_isInitialized || _model == null) {
      yield l10n.errorServiceNotInitialized;
      return;
    }
    _isGenerationCancelled = false;
    try {
      final chat = await _model!.createChat(
        temperature: 0.7,
        topK: 40,
      );
      final message = Message.text(text: text, isUser: true);
      await chat.addQueryChunk(message);

      await for (final response in chat.generateChatResponseAsync()) {
        if (_isGenerationCancelled) break;
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } catch (e) {
      debugPrint("Ошибка генерации ответа: $e");
      yield l10n.errorStreamFailed(e.toString());
    } finally {
      _isGenerationCancelled = false;
    }
  }

  @override
  void dispose() {
    _model?.close();
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    _interstitialAdLoader?.cancelLoading();
    _appOpenAdLoader?.cancelLoading();
    _appOpenAd = null;

    super.dispose();
  }
}
