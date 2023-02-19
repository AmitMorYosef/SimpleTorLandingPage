import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../../app_const/app_version.dart';

class FirebseRometeConfig {
  static final remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initSrvice() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 7),
      minimumFetchInterval: const Duration(seconds: 1),
    ));
    await remoteConfig.fetchAndActivate();
  }

  static Map<dynamic, dynamic> getVersionInfo() {
    final val = remoteConfig.getString(versionInfoKey);
    return jsonDecode(val);
  }

  static List<String> getDevelopers() {
    final val = remoteConfig.getString(developersKey);
    return jsonDecode(val).keys.toList();
  }

  static bool isAppInMaintanence() {
    return remoteConfig.getBool(maintenanceKey);
  }

  // static int getNewBusinessTrialDays() {
  //   return remoteConfig.getInt(newBusinessTrialDaysKey);
  // }
}
