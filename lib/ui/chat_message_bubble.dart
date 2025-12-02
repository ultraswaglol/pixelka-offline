import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/models/chat_message.dart';
import 'package:pixelka_offline/theme/app_theme.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

void _copyToClipboard(
    String text, BuildContext context, AppLocalizations l10n) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.copiedToClipboard),
      duration: const Duration(seconds: 2),
    ),
  );
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.isUser;

    Widget textWidget;

    if (isUser) {
      textWidget = Text(
        message.text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      );
    } else {
      textWidget = MarkdownBody(
        data: message.text,
        onTapLink: (text, href, title) {
          if (href != null) {
            try {
              launchUrl(Uri.parse(href));
            } catch (e) {
              debugPrint("Could not launch $href: $e");
            }
          }
        },
        builders: {
          'pre': _PreElementBuilder(context, l10n),
          'code': _InlineCodeElementBuilder(),
        },
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          p: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            backgroundColor:
                theme.colorScheme.surface.withAlpha((255 * 0.5).round()),
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
    }

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: AppTheme.kDefaultPadding / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              child: const Icon(Icons.memory_rounded, size: 20),
            ),
          if (!isUser) const SizedBox(width: AppTheme.kDefaultPadding),
          Flexible(
            child: GestureDetector(
              onLongPress: isUser
                  ? null
                  : () {
                      _copyToClipboard(message.text, context, l10n);
                    },
              child: Container(
                padding: const EdgeInsets.all(AppTheme.kDefaultPadding * 1.5),
                decoration: BoxDecoration(
                  color: isUser
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.kDefaultRadius),
                ),
                child: textWidget,
              ),
            ),
          ),
          if (isUser) const SizedBox(width: AppTheme.kDefaultPadding),
          if (isUser)
            CircleAvatar(
              backgroundColor: theme.colorScheme.tertiaryContainer,
              foregroundColor: theme.colorScheme.onTertiaryContainer,
              child: const Icon(Icons.person, size: 20),
            ),
        ],
      ),
    );
  }
}

class _InlineCodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return RichText(
      text: TextSpan(
        text: element.textContent,
        style: preferredStyle,
      ),
    );
  }
}

class _PreElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final AppLocalizations l10n;
  _PreElementBuilder(this.context, this.l10n);

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.children == null || element.children!.isEmpty) {
      return const SizedBox();
    }

    final codeElement = element.children!.first as md.Element;
    final String codeText = codeElement.textContent;

    // Получаем язык
    String? language;
    if (codeElement.attributes['class'] != null) {
      language =
          codeElement.attributes['class']?.replaceFirst('language-', '').trim();
    }
    final String? lang = language;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.kDefaultPadding),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppTheme.kDefaultPadding,
              (lang != null && lang.isNotEmpty)
                  ? AppTheme.kDefaultPadding * 3.5
                  : AppTheme.kDefaultPadding * 1.5,
              AppTheme.kDefaultPadding,
              AppTheme.kDefaultPadding * 1.5,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.4).round()),
              borderRadius: BorderRadius.circular(AppTheme.kDefaultRadius / 2),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                codeText,
                style: preferredStyle?.copyWith(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),

          // Лейбл языка (если есть)
          if (lang != null && lang.isNotEmpty)
            Positioned(
              top: 10,
              left: 12,
              child: Text(
                lang,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              color: Colors.grey[400],
              splashRadius: 20,
              tooltip: "Скопировать код",
              onPressed: () {
                _copyToClipboard(codeText, context, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }
}
