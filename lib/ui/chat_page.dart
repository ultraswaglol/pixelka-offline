import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Добавлено для вибрации
import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/llm_service.dart';
import 'package:pixelka_offline/models/chat_message.dart';
import 'package:pixelka_offline/models/chat_meta_data.dart';
import 'package:pixelka_offline/models/llm_status.dart';
import 'package:pixelka_offline/theme/app_theme.dart';
import 'package:pixelka_offline/ui/chat_message_bubble.dart';
import 'package:pixelka_offline/ui/model_loading_indicator.dart';
import 'package:pixelka_offline/ui/model_selection_page.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String? chatId; // ID существующего чата
  final String? defaultTitle; // Название для нового чата

  const ChatPage({
    super.key,
    this.chatId,
    this.defaultTitle,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isResponding = false;
  ChatMetaData? _metaData; // Информация о текущем чате

  late String _chatId;
  bool _isLoadingChat = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatInfo();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _goToModelSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final service = context.read<LlmService>();
          return Scaffold(
            appBar: AppBar(title: Text(l10n.chatPageTitle)),
            body: ModelSelectionPage(service: service, l10n: l10n),
          );
        },
      ),
    );
  }

  Future<void> _loadChatInfo() async {
    final llmService = context.read<LlmService>();
    String idToLoad;

    if (widget.chatId == null) {
      final newChat =
          await llmService.createNewChat(widget.defaultTitle ?? "New Chat");
      idToLoad = newChat.id;
    } else {
      idToLoad = widget.chatId!;
    }

    final meta = llmService.getChatMeta(idToLoad);
    final history = await llmService.getMessages(idToLoad);

    setState(() {
      _chatId = idToLoad;
      _metaData = meta;
      _messages = history;
      _isLoadingChat = false;
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final llmService = context.read<LlmService>();
    String text = _controller.text.trim();

    if (text.isEmpty || _isResponding || _isLoadingChat) return;

    if (!llmService.isInitialized) {
      _goToModelSelection(context);
      return;
    }

    // ✅ UX: Легкая вибрация при отправке
    await HapticFeedback.lightImpact();

    _controller.clear();

    final userMessage = ChatMessage(text, isUser: true);

    setState(() {
      _messages.add(userMessage);
      _messages.add(ChatMessage("")); // UI-заглушка для ответа
      _isResponding = true;
    });
    _scrollToBottom();

    // ✅ FIX: Сохраняем сообщение пользователя СРАЗУ.
    // Если приложение вылетит во время генерации, вопрос останется в истории.
    await llmService.addMessage(_chatId, userMessage);

    // Вызываем рекламу (твоя текущая логика)
    llmService.maybeShowInterstitialAd();

    String fullResponse = "";
    String errorResponse = "";
    try {
      await for (final token
          in llmService.generateTextResponse(text, l10n, _chatId)) {
        fullResponse += token;
        setState(() {
          _messages.last = ChatMessage(fullResponse, isUser: false);
          _scrollToBottom();
        });
      }
      // ✅ UX: Вибрация при успешном завершении
      await HapticFeedback.selectionClick();
    } catch (e) {
      errorResponse = "Ошибка стрима: $e";
      setState(() {
        _messages.last = ChatMessage(errorResponse, isUser: false);
      });
    } finally {
      ChatMessage finalBotMessage;
      if (errorResponse.isNotEmpty) {
        finalBotMessage = ChatMessage(errorResponse, isUser: false);
      } else if (fullResponse.isNotEmpty) {
        finalBotMessage = ChatMessage(fullResponse, isUser: false);
      } else {
        // Если ответ пустой (например, отмена), убираем заглушку
        setState(() {
          _messages.removeLast();
        });
        finalBotMessage = ChatMessage("", isUser: false);
      }

      // ✅ FIX: Пользователя уже сохранили выше, тут сохраняем только ответ бота
      if (finalBotMessage.text.isNotEmpty) {
        setState(() {
          _messages.last = finalBotMessage;
        });
        await llmService.addMessage(_chatId, finalBotMessage);
      }

      setState(() {
        _isResponding = false;
      });

      // Логика переименования первого чата
      if (_messages.length == 2 && fullResponse.isNotEmpty) {
        final newTitle =
            text.length > 50 ? "${text.substring(0, 50)}..." : text;
        await llmService.renameChat(_chatId, newTitle);
        setState(() {
          _metaData?.title = newTitle;
        });
      }
    }
  }

  void _clearChatHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final llmService = context.read<LlmService>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chatClearHistory),
        content: Text(l10n.chatClearHistoryContent),
        actions: [
          TextButton(
            child: Text(l10n.dialogCancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(l10n.chatClearHistoryButton),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && !_isLoadingChat) {
      await llmService.clearHistory(_chatId);
      setState(() {
        _messages.clear();
      });
    }
  }

  Widget _buildTopIndicator(
      BuildContext context, LlmService service, AppLocalizations l10n) {
    final bool isActuallyLoading =
        service.isLoading || service.status == LlmStatus.error;
    final bool needsBatteryFix = service.batteryOptimizationWarningKey != null;

    if (isActuallyLoading || needsBatteryFix) {
      return ModelLoadingIndicator(service: service, l10n: l10n);
    }

    if (!service.isInitialized) {
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 1,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
            child: TextButton.icon(
              onPressed: () => _goToModelSelection(context),
              icon: const Icon(Icons.memory_outlined),
              label: Text(l10n.snackBarSelectModel),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final llmService = context.watch<LlmService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoadingChat ? l10n.loadingChat : (_metaData?.title ?? "Chat"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.chatClearHistoryButton,
            onPressed: _isResponding ? null : _clearChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopIndicator(context, llmService, l10n),
          Expanded(
            child: _isLoadingChat
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ChatMessageBubble(message: msg);
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.chatHint,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                if (_isResponding)
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined),
                    onPressed: llmService.cancelGeneration,
                    color: Colors.red,
                    tooltip: "Остановить генерацию",
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: (_isResponding || !llmService.isInitialized)
                        ? null
                        : _sendMessage,
                    disabledColor: Colors.grey,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
