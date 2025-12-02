import 'package:flutter/material.dart';
import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/llm_service.dart';
import 'package:pixelka_offline/models/chat_meta_data.dart';
import 'package:pixelka_offline/models/llm_status.dart';
import 'package:pixelka_offline/theme/app_theme.dart';
import 'package:pixelka_offline/ui/chat_page.dart';
import 'package:pixelka_offline/ui/model_loading_indicator.dart';
import 'package:pixelka_offline/ui/model_selection_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LlmService>().loadAndShowAppOpenAd();
    });
  }

  void _createNewChat(BuildContext context, LlmService service) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          defaultTitle: l10n.newChatTitle,
        ),
      ),
    );
  }

  void _renameChat(
      BuildContext context, LlmService service, ChatMetaData chat) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: chat.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.renameChatTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.renameChatHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  service.renameChat(chat.id, newTitle);
                  Navigator.of(context).pop();
                }
              },
              child: Text(l10n.renameButton),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat(
      BuildContext context, LlmService service, ChatMetaData chat) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteChatTitle),
          content: Text(l10n.deleteChatContent(chat.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () {
                service.deleteChat(chat.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.dialogDelete),
            ),
          ],
        );
      },
    );
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

  Widget _buildModelStatusAction(
      BuildContext context, LlmService service, AppLocalizations l10n) {
    if (service.isInitialized) {
      return IconButton(
        icon: const Icon(Icons.drive_file_rename_outline_rounded),
        tooltip: l10n.appBarTooltipChangeModel,
        onPressed: service.isLoading ? null : service.unloadModel,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.memory_outlined),
        tooltip: l10n.snackBarSelectModel,
        onPressed: () => _goToModelSelection(context),
      );
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
    final llmService = context.watch<LlmService>();
    final l10n = AppLocalizations.of(context)!;
    final chats = llmService.getChatList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myChatsTitle),
        actions: [
          _buildModelStatusAction(context, llmService, l10n),
        ],
      ),
      body: Column(
        children: [
          _buildTopIndicator(context, llmService, l10n),
          Expanded(
            child: chats.isEmpty
                ? Center(
                    child: Text(
                      l10n.noChatsYet,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final formattedDate =
                          DateFormat('dd.MM.yyyy HH:mm').format(chat.createdAt);
                      return ListTile(
                        title: Text(chat.title),
                        subtitle: Text(l10n.chatItemSubtitle(formattedDate)),
                        leading: const Icon(Icons.chat_bubble_outline),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(chatId: chat.id),
                            ),
                          );
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: Text(l10n.renameButton),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _renameChat(context, llmService, chat);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.delete_outline,
                                      color: Colors.red[400]),
                                  title: Text(
                                    l10n.dialogDelete,
                                    style: TextStyle(color: Colors.red[400]),
                                  ),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _deleteChat(context, llmService, chat);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewChat(context, llmService),
        icon: const Icon(Icons.add),
        label: Text(l10n.newChatButton),
      ),
    );
  }
}
