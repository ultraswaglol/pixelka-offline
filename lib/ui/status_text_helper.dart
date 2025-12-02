import 'package:pixelka_offline/l10n/app_localizations.dart';
import 'package:pixelka_offline/llm_service.dart';
import 'package:pixelka_offline/models/llm_status.dart';

class StatusTextHelper {
  static String buildStatusText(LlmService service, AppLocalizations l10n) {
    final modelName = service.currentModel?.displayName ?? '...';

    switch (service.status) {
      case LlmStatus.uninitialized:
        return service.lastError != null
            ? l10n.statusError(service.lastError!)
            : l10n.modelNotSelected;
      case LlmStatus.initializing:
        return l10n.statusInitializing(modelName);
      case LlmStatus.downloading:
        return l10n.statusDownloading(modelName, service.progress);
      case LlmStatus.registering:
        return l10n.statusRegistering(modelName);
      case LlmStatus.loading:
        return l10n.statusLoading(modelName);
      case LlmStatus.ready:
        return l10n.statusReady(modelName);
      case LlmStatus.error:
        return l10n.statusError(service.lastError ?? l10n.errorUnknown);
      case LlmStatus.unloading:
        return l10n.statusUnloading;
    }
  }
}
