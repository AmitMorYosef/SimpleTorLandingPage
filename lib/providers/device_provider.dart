import 'package:flutter/material.dart';
import 'package:management_system_app/services/clients/secured_storage_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_const/application_general.dart';
import '../app_const/device_keys.dart';
import '../app_const/platform.dart';
import '../ui/ui_manager.dart';

class DeviceProvider extends ChangeNotifier {
  bool isAllowedNotification = false; // user allowed app notifications or not
  int minutesBeforeNotify = 15; // duration before turn the app should notify

  Future<void> notificationSettingsInit() async {
    isAllowedNotification = await SecuredStorageClient()
                .readKeyInDeviceStorage(key: allowedNotificationKey) ==
            'true' &&
        (isWeb || await Permission.notification.status.isGranted);
    final minutesBeforeNotifyString = await SecuredStorageClient()
        .readKeyInDeviceStorage(key: durationbeforeNotifyKey);
    minutesBeforeNotify = minutesBeforeNotifyString == ''
        ? 15
        : int.parse(minutesBeforeNotifyString);
  }

  Future<bool> updateIsAllowedNotification(bool isAllowed) async {
    this..isAllowedNotification = isAllowed;
    UiManager.insertUpdate(Providers.device);
    bool resp = await SecuredStorageClient().updateKeyInDeviceStorage(
        key: allowedNotificationKey, value: isAllowed.toString());
    if (!resp) this..isAllowedNotification = !isAllowed;

    return resp;
  }

  Future<void> updateDurationBeforeNotify(
      {required int newMinutesBeforeNotify,
      required BuildContext context}) async {
    this..minutesBeforeNotify = newMinutesBeforeNotify;
    UiManager.insertUpdate(Providers.device);
    UiManager.updateUi(context: context);
    await SecuredStorageClient().updateKeyInDeviceStorage(
        key: durationbeforeNotifyKey, value: newMinutesBeforeNotify.toString());
  }

  void updateScreen() => notifyListeners();
}
