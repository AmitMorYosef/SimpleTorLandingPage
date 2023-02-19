import 'package:flutter/material.dart';
import 'package:management_system_app/ui/ui_manager.dart';

import '../app_const/application_general.dart';
import '../app_const/device_keys.dart';
import '../app_const/display.dart';
import '../app_const/resources.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/theme_data.dart';
import '../services/clients/secured_storage_client.dart';
import '../utlis/general_utlis.dart';

class ThemeProvider extends ChangeNotifier {
  Future<bool> changeTheme(
    BuildContext context,
    Themes theme,
  ) async {
    if (AppThemeData.currentKeyTheme != theme) {
      switch (theme) {
        case Themes.light:
          SettingsData.businessIcon = darkShopIcon;
          break;
        case Themes.dark:
          SettingsData.businessIcon = lightShopIcon;
          break;
      }
      AppThemeData.themeCauseMainBuilt = true;

      SecuredStorageClient().updateKeyInDeviceStorage(
          key: lastBuisnessThemeKey, value: themeToStr[theme]!);

      AppThemeData.currentKeyTheme = theme;
      overLaysHandling();
      UiManager.insertUpdate(Providers.theme);
      return true;
    }
    return false;
  }

  void updateScreen() => notifyListeners();
}
