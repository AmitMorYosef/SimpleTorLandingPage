import 'package:management_system_app/services/clients/secured_storage_client.dart';

import '../app_const/device_keys.dart';
import '../app_const/display.dart';
import '../app_const/platform.dart';

class AppThemeData {
  static Themes defaultTheme = Themes.dark;
  static Themes? currentKeyTheme;
  static bool themeCauseMainBuilt = false; // main rebuild becuase theme changed

  /// load the theme that saved on the user's device
  static Future<void> loadSavedTheme() async {
    if (isWeb) {
      return;
    }
    String key = await SecuredStorageClient()
        .readKeyInDeviceStorage(key: lastBuisnessThemeKey);
    if (themeFromStr.containsKey(key) &&
        themes.containsKey(themeFromStr[key]!)) {
      defaultTheme = themeFromStr[key]!;
    }
  }
}
