import 'package:flutter/material.dart';
import 'package:pixelka_offline/llm_service.dart';
import 'package:pixelka_offline/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pixelka_offline/models/chat_message.dart';
import 'package:pixelka_offline/models/chat_meta_data.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixelka_offline/l10n/app_localizations.dart';

import 'package:pixelka_offline/ui/home_page.dart';

import 'package:yandex_mobileads/mobile_ads.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await MobileAds.initialize();

  await Hive.initFlutter('gemma_lab_cache');
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatMetaDataAdapter());

  await Hive.openBox<ChatMetaData>('chat_list');

  await FlutterDownloader.initialize(
    debug: true,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LlmService(),
      child: const GemmaLabApp(),
    ),
  );
}

class GemmaLabApp extends StatelessWidget {
  const GemmaLabApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appTitle;
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', ''),
      ],
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
