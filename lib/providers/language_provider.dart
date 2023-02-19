import 'package:flutter/material.dart';
import 'package:management_system_app/app_statics.dart/subscription_data.dart';
import 'package:management_system_app/ui/ui_manager.dart';

import '../app_const/application_general.dart';
import '../app_const/device_keys.dart';
import '../app_statics.dart/language_data.dart';
import '../services/clients/secured_storage_client.dart';

class LanguageProvider extends ChangeNotifier {
  Map<String, String> supportedLanguages = {'en': 'english', 'he': 'עברית'};

  int get amountOfLanguages => this.supportedLanguages.length;

  Future<void> changeLaguage(String languageCode) async {
    if (languageCode == LanguageData.currentLaguageCode) return;
    if (!this.supportedLanguages.containsKey(languageCode)) return;
    SubscriptionData.initDetails();
    SecuredStorageClient()
        .updateKeyInDeviceStorage(key: deviceLanguageKey, value: languageCode);
    LanguageData.currentLaguageCode = languageCode;
    UiManager.insertUpdate(Providers.language);
    /* changing the app language */
  }

  void updateScreen() => notifyListeners();
}
