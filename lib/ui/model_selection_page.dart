import 'package:flutter/material.dart';
import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/llm_service.dart';
import 'package:pixelka_offline/theme/app_theme.dart';
import 'package:pixelka_offline/models/llm_status.dart';

class ModelSelectionPage extends StatelessWidget {
  final LlmService service;
  final AppLocalizations l10n;

  const ModelSelectionPage({
    super.key,
    required this.service,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.modelSelectionWelcome,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.kDefaultPadding * 2),
          Text(
            l10n.modelSelectionPrompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.kDefaultPadding * 4),
          ...service.availableModels.map(
            (model) => Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.kDefaultPadding / 2),
              child: ElevatedButton(
                onPressed: () {
                  service.initialize(model);
                  Navigator.of(context).pop();
                },
                child: Text(model.displayName),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.kDefaultPadding * 3),
          // Но в основном она будет в ModelLoadingIndicator
          if (service.batteryOptimizationWarningKey != null)
            Card(
              color: Colors.yellow.withAlpha((255 * 0.3).round()),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.kDefaultPadding * 1.5),
                child: Column(
                  children: [
                    Text(
                      l10n.batteryWarning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppTheme.kDefaultPadding),
                    ElevatedButton(
                      onPressed: service.requestBatteryOptimizationBypass,
                      child: Text(l10n.batteryWarningButton),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppTheme.kDefaultPadding * 2),
          TextButton.icon(
            onPressed: service.isLoading
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.clearStorageDialogTitle),
                        content: Text(l10n.clearStorageDialogContent),
                        actions: [
                          TextButton(
                            child: Text(l10n.dialogCancel),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text(l10n.dialogDelete),
                            onPressed: () {
                              Navigator.of(context).pop();
                              service.clearDownloadedModels();
                            },
                          ),
                        ],
                      ),
                    );
                  },
            icon: const Icon(Icons.delete_sweep_outlined, size: 16),
            label: Text(l10n.clearStorageButton),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),
          const SizedBox(height: AppTheme.kDefaultPadding * 2),
          if (service.status == LlmStatus.error)
            Text(
              l10n.statusError(service.lastError ?? l10n.errorUnknown),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
