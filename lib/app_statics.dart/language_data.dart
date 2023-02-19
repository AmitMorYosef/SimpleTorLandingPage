import 'dart:io';

import 'package:management_system_app/services/clients/secured_storage_client.dart';

import '../app_const/device_keys.dart';
import '../app_const/platform.dart';

class LanguageData {
  static String currentLaguageCode = '';

  static Future<void> loadSavedLanguage() async {
    // if (isWeb) {
    //   return;
    // }
    String savedLanguage = await SecuredStorageClient()
        .readKeyInDeviceStorage(key: deviceLanguageKey);

    currentLaguageCode = savedLanguage;
    if (isWeb) {
      if (savedLanguage == "") {
        currentLaguageCode = 'he';
      }
      return;
    }
    if (savedLanguage == "") {
      final langCode = Platform.localeName.split("_")[0];

      if (langCode == "he") {
        currentLaguageCode = langCode;
      } else {
        currentLaguageCode = "en";
      }
    }
  }
}
