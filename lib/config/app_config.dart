import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get hfToken {
    return dotenv.env['HF_TOKEN'] ?? '';
  }

  static String get interstitialAdId {
    return dotenv.env['INTERSTITIAL_AD_ID'] ?? '';
  }

  static String get appOpenAdId {
    return dotenv.env['APP_OPEN_AD_ID'] ?? '';
  }
}
