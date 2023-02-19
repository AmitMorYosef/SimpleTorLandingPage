import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/models/buisnesses_preview_model.dart';
import 'package:simple_tor_web/providers/user_provider.dart';
import 'package:simple_tor_web/providers/worker_provider.dart';
import 'package:simple_tor_web/services/errors_service/app_errors.dart';
import 'package:simple_tor_web/services/errors_service/settings.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';

import '../app_const/application_general.dart';
import '../app_const/db.dart';
import '../app_const/device_keys.dart';
import '../app_const/display.dart';
import '../app_statics.dart/screens_data.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/theme_data.dart';
import '../app_statics.dart/user_data.dart';
import '../services/clients/firestore_client.dart';
import '../services/clients/secured_storage_client.dart';
import '../services/errors_service/messages.dart';
import '../utlis/general_utlis.dart';
import '../utlis/string_utlis.dart';

class SettingsProvider extends ChangeNotifier {
  // ---------------------buisness -------------------------

  Future<bool> setupPreviewBuisnesses() async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.setupPreviewBuisnesses]);
    return await FirestoreClient()
        .getAllDocInsideCollection(path: '$buisnessesPreviewCollection')
        .then((json) {
      if (json != null)
        SettingsData.buisnessesPreview = BuisnessesPreview.fromJson(json);

      return json != null;
    });
  }

  Future<bool> loadBuisness(BuildContext context, String buisnessId,
      {bool fromLoading = false}) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.loadBuisness]);
    //clean business data
    ScreensData.initOffests();
    ScreensData.changingPhotoIndex = 0;
    SettingsData.emptyBusinessData();
    UserData.currentBuisness = '';
    try {
      final buisnesses = SettingsData.buisnessesPreview.buisnesses;

      if (!buisnesses.containsKey(buisnessId)) {
        logger.i("Buisness isnt exist");
        AppErrors.error = Errors.notFoundItem;

        if (fromLoading) {
          return true;
        }
        return false;
      }
      // the settings
      bool resp = await SettingsData.initSettings(buisnessId, context);
      if (resp) {
        if (UserData.user.permission.containsKey(buisnessId)) {
          await context.read<WorkerProvider>().setUpWorker(
              userPhone: UserData.user.phoneNumber, context: context);
        }

        //we dont want to init the buisness when theme is changes
        if (!AppThemeData.themeCauseMainBuilt) ScreensData.buisnessInit = false;

        //add to the last visited buisnesses
        if (UserData.user.name != translate("guest") &&
            await isNetworkConnected()) {
          if (UserData.user.lastVisitedBuisnesses.contains(buisnessId)) {
            await context
                .read<UserProvider>()
                .replaceVisitedBuisness(buisnessId, buisnessId);
          } else {
            context.read<UserProvider>().addVisitedBuisness(buisnessId);
          }
        }
        // save the last buisness
        await SettingsData.updateLastBuisness(buisnessId);

        UiManager.insertUpdate(Providers.settings);
        return true;
      } else {
        AppErrors.error = Errors.unknown;
        return false;
      }
    } catch (e) {
      logger.e("Error loading settings --> $e");
      //check if buisness exist
      await SettingsData.emptyBusinessData();
      final buisnesses = SettingsData.buisnessesPreview.buisnesses;
      if (!buisnesses.containsKey(buisnessId)) {
        logger.i("Buisness isnt exist");

        AppErrors.error = Errors.notFoundItem;
      } else {
        AppErrors.error = Errors.unknown;
      }
      return true;
    }
  }

  Future<void> changeTheme(Themes theme) async {
    SettingsData.settings.theme = theme;
    await FirestoreClient().updateFieldInsideDocAsMap(
        fieldName: 'theme',
        docId: SettingsData.appCollection,
        path: buisnessCollection,
        value: themeToStr[theme]!);
  }

  Future<bool> loadLastBuisness(BuildContext context,
      {bool fromLoading = false}) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.loadLastBuisness]);
    String key = "972-504040624--e6b8f8e0-a7b3-11ed-894b-dda94c48fa31";

    await SecuredStorageClient().readKeyInDeviceStorage(key: lastBuisnessIdKey);
    logger.d("Saved business key is --> $key");
    if (key != '')
      await loadBuisness(context, key, fromLoading: fromLoading).then((value) {
        if (value) {
        } else {
          logger.d("Failed to load the business");

          //if fail we want to delete all the data that already pass
          SettingsData.emptyBusinessData();
        }
      });
    return true;
  }

  void updateScreen() => notifyListeners();
}
