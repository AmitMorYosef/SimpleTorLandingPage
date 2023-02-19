import 'dart:io';

import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/links_provider.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/services/errors_service/loading.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../app_const/app_version.dart';
import '../app_const/loading_statuses.dart';
import '../app_const/platform.dart';
import '../app_statics.dart/general_data.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/theme_data.dart';
import '../app_statics.dart/user_data.dart';
import '../services/errors_service/app_errors.dart';
import '../services/external_services/firebase_remote_config.dart';
import '../utlis/general_utlis.dart';
import 'device_provider.dart';

class LoadingProvider extends ChangeNotifier {
  LoadingStatuses status = LoadingStatuses.loading;

  Future<void> loadAppData(
      {required SettingsProvider settingsProvider,
      required LinksProvider linksProvider,
      required BuildContext context}) async {
    if (this.status != LoadingStatuses.loading) return;
    if (AppThemeData.themeCauseMainBuilt) {
      this.status = LoadingStatuses.success;
      AppErrors.addError(code: loadingCodeToInt[LoadingErrorCodes.loadAppData]);
      return;
    }

    // try {
    //   /*For case that user has incorrect display name
    //     need to login from start*/
    //   if (UserData.isConnected()) {
    //     client.getUserPhone();
    //   }
    // } catch (e) {
    //   UserData.logout();
    // } ask shilo

    try {
      // initialize the remote config service
      if (linksProvider.appFirstTime) {
        await FirebseRometeConfig.initSrvice();
      }
    } catch (e) {
      logger.e("Error while get the remote config --> $e");
    }
    try {
      if (FirebseRometeConfig.isAppInMaintanence()) {
        updateStatus(LoadingStatuses.maintenanceMode);
        return;
      }
    } catch (e) {
      AppErrors.details = "2 --> " + e.toString();
      updateStatus(LoadingStatuses.unknownError);

      return;
    }

    try {
      if (linksProvider.appFirstTime && await checkForUpdates()) {
        //need
        updateStatus(LoadingStatuses.updateAvilable);
        return;
      } // chck for updates
    } catch (e) {
      AppErrors.details = "3 --> " + e.toString();
      updateStatus(LoadingStatuses.unknownError);

      return;
    }
    try {
      if (!await isTimeUpdated()) {
        // check device date & time
        this.updateStatus(LoadingStatuses.timeEror);
        return;
      }
    } catch (e) {
      AppErrors.details = "4 --> " + e.toString();
      updateStatus(LoadingStatuses.unknownError);
      return;
    }

    try {
      SettingsData.developers = FirebseRometeConfig.getDevelopers();
    } catch (e) {
      AppErrors.details = "5 --> " + e.toString();
      updateStatus(LoadingStatuses.unknownError);
      return;
    }
    try {
      if (!await executeFuture(settingsProvider.setupPreviewBuisnesses))
        return; // preview data for search
    } catch (e) {
      AppErrors.details = "6 --> " + e.toString();
      updateStatus(LoadingStatuses.unknownError);
      return;
    }
    try {
      if (UserData.isConnected()) {
        // load the user data
        bool successfullyLoaded = await loadUserData(context);
        if (!successfullyLoaded) {
          return;
        }
      }
    } catch (e) {
      context.read<UserProvider>().logout();
      AppErrors.details = "7 --> ${UserData.isConnected()} " + e.toString();
      updateStatus(LoadingStatuses.unknownError);
      return;
    }

    try {
      await linksProvider.handleOpenAppLink();
      String linkBuisnessId = linksProvider.linkedBuisnessId;

      if (linkBuisnessId == '') {
        // no link
        logger.i(
            'LinkBuisnessId is empty (client is) ->  ${GeneralData.currentBusinesssId}');
        if (GeneralData.currentBusinesssId == '') {
          // regular entrance - chck for chace
          if (!await executeFuture(() =>
              settingsProvider.loadLastBuisness(context, fromLoading: true)))
            return;
        } else {
          // notifications put id
          if (!await executeFuture(() => context
              .read<SettingsProvider>()
              .loadBuisness(context, GeneralData.currentBusinesssId,
                  fromLoading: true))) return;
        }
      } else {
        // link entrance - take id from link
        linksProvider.linkedBuisnessId = ''; //reset link for next entrance
        if (!await executeFuture(() => context
            .read<SettingsProvider>()
            .loadBuisness(context, linkBuisnessId))) return;
      }
    } catch (e) {
      AppErrors.details = "8 --> ${UserData.isConnected()} " + e.toString();
      updateStatus(LoadingStatuses.unknownError);
      return;
    }

    // get isAlloedNotifications & time before notify - (device settings)
    await context.read<DeviceProvider>().notificationSettingsInit();

    updateStatus(LoadingStatuses.success);
  }

  Future<bool> loadUserData(BuildContext context) async {
    // load the user
    if (!await executeFuture(() => context.read<UserProvider>().setupUser()))
      return false;
    return true;
  }

  void updateScreen() {
    notifyListeners();
  }

  void updateStatus(LoadingStatuses status) {
    logger.i("Status is updated to --> $status");
    this.status = status;
    UiManager.insertUpdate(Providers.loading);
  }

  Future<bool> executeFuture(Future<bool> Function() func) async {
    AppErrors.addError(code: loadingCodeToInt[LoadingErrorCodes.executeFuture]);
    bool resp = await func();
    if (!resp) updateStatus(LoadingStatuses.unknownError);
    return resp;
  }

  int parseVersionToInt(String version) {
    /* vaersion - x.x.x 
    output - xxx*/
    List<String> versionSegments = version.split('.');
    int versionNum = 0;
    versionSegments.forEach((element) {
      versionNum = (versionNum * 10) + int.parse(element);
    });
    return versionNum;
  }

  Future<bool> checkForUpdates() async {
    if (isWeb) {
      return false;
    }
    // getting current vaersion
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = parseVersionToInt(packageInfo.version);

    Map<String, dynamic> versionInfo = {};
    FirebseRometeConfig.getVersionInfo()
        .forEach((key, value) => versionInfo['$key'] = value);
    if (!versionInfo.containsKey(androidVersionKey) ||
        !versionInfo.containsKey(iosVersionKey)) {
      // there is a problem don't stuck the application
      return false;
    }
    if (Platform.isAndroid) {
      int androidVersion = parseVersionToInt(versionInfo[androidVersionKey]);
      return appVersion < androidVersion;
    }
    if (Platform.isIOS) {
      int iosVersion = parseVersionToInt(versionInfo[iosVersionKey]);
      return appVersion < iosVersion;
    }
    return false;
  }
}
