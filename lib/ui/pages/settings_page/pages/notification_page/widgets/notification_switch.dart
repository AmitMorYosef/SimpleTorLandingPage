import 'package:flutter/material.dart';
import 'package:management_system_app/providers/device_provider.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_const/notification.dart';
import '../../../../../../app_const/platform.dart';
import '../../../../../../app_statics.dart/user_data.dart';
import '../../../../../../utlis/notifications_utlis.dart';
import '../../../../../general_widgets/dialogs/genral_dialog.dart';

class NotificationSwitch extends StatefulWidget {
  void Function()? afterAllowed;
  NotificationSwitch({super.key, this.afterAllowed});

  @override
  State<NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<NotificationSwitch> {
  late bool isAllowed = false;
  late BuildContext context;
  late SettingsProvider settingsProvider;
  late DeviceProvider deviceProvider;

  @override
  Widget build(BuildContext _context) {
    context = _context;
    settingsProvider = context.read<SettingsProvider>();
    deviceProvider = context.read<DeviceProvider>();

    context.watch<DeviceProvider>();
    return Container(
      height: 20,
      width: 25,
      child: Switch(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: context.read<DeviceProvider>().isAllowedNotification,
        onChanged: (value) async {
          beforeChangeAllowNotifications(value);
        },
      ),
    );
  }

  Future<void> beforeChangeAllowNotifications(bool value) async {
    if (!value) {
      bool? resp = true;
      if (UserData
          .user.subToNotifications[NotifySorts.waitingList]!.isNotEmpty) {
        resp = await genralDialog(
          context: context,
          content: Text(
            translate("youWillRemoveFromWaitingLists"),
            textAlign: TextAlign.center,
          ),
          title: translate("turnOffNotifications?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(translate("no")),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(translate("yes")),
            ),
          ],
        );
      }
      if (resp == true) {
        onChanged(value);
      }
    } else {
      checkForNotificationPermission(value);
    }
  }

  Future<void> checkForNotificationPermission(bool value) async {
    if (isWeb) {
      return;
      //onChanged(value);
    }
    var status = await Permission.notification.status;
    if (status.isGranted) {
      await onChanged(value);
      if (widget.afterAllowed != null) {
        widget.afterAllowed!();
      }
    } else {
      await genralDialog(
          context: context,
          title: translate("noPemission"),
          content: Text(
            translate("needToAllowNotificationInSettings"),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translate("ok")))
          ]);
    }
  }

  Future<void> onChanged(bool value) async {
    deviceProvider.updateIsAllowedNotification(value);
    if (value) {
      bringBackAllNotifications(
        context.read<DeviceProvider>().isAllowedNotification,
        context.read<DeviceProvider>().minutesBeforeNotify,
      );
      context.read<UserProvider>().deviceTurnOnNotifications();
      UiManager.updateUi(context: context);
    } else {
      deleteNotifications();
    }

    setState(() {
      isAllowed = value;
    });
  }

  Future<bool> deleteNotifications() async {
    await deleteAllNotifications();
    bool resp = await context.read<UserProvider>().deviceTurnOffNotifications();
    return resp;
  }
}
