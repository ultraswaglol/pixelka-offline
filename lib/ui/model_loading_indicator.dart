import 'package:flutter/material.dart';
import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/llm_service.dart';
import 'package:pixelka_offline/models/llm_status.dart';
import 'package:pixelka_offline/theme/app_theme.dart';
import 'package:pixelka_offline/ui/status_text_helper.dart';

class ModelLoadingIndicator extends StatelessWidget {
  final LlmService service;
  final AppLocalizations l10n;

  const ModelLoadingIndicator({
    super.key,
    required this.service,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDownloading =
        service.isLoading && service.status == LlmStatus.downloading;
    final bool isProcessing = service.isLoading &&
        (service.status == LlmStatus.initializing ||
            service.status == LlmStatus.registering ||
            service.status == LlmStatus.loading);
    final bool hasError = service.status == LlmStatus.error;
    final bool needsBatteryFix = service.batteryOptimizationWarningKey != null;

    if (!isDownloading && !isProcessing && !hasError && !needsBatteryFix) {
      return const SizedBox.shrink();
    }

    final String statusText = StatusTextHelper.buildStatusText(service, l10n);

    return Material(
      color: hasError
          ? Colors.red.withAlpha(51)
          : Theme.of(context).colorScheme.surfaceContainer,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (isDownloading || isProcessing)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: isDownloading
                        ? CircularProgressIndicator(
                            value: (service.progress > 0)
                                ? service.progress / 100.0
                                : null,
                            strokeWidth: 2,
                          )
                        : const CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (hasError)
                  Icon(Icons.error_outline, color: Colors.red[300], size: 20),
                const SizedBox(width: AppTheme.kDefaultPadding * 2),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: hasError ? Colors.red[300] : null,
                    ),
                  ),
                ),
              ],
            ),
            if (needsBatteryFix)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.kDefaultPadding),
                child: Column(
                  children: [
                    Text(
                      l10n.batteryWarning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    const SizedBox(height: AppTheme.kDefaultPadding),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.kDefaultPadding,
                            horizontal: AppTheme.kDefaultPadding * 2),
                      ),
                      onPressed: service.requestBatteryOptimizationBypass,
                      child: Text(l10n.batteryWarningButton),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
