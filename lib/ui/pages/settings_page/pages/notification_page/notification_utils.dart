import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/notification_page/widgets/notify_when_on_waiting_list_events.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/resources.dart';
import '../../../../../app_statics.dart/settings_data.dart';
import '../../../../../providers/device_provider.dart';
import '../../../../../providers/manager_provider.dart';
import '../../../../../utlis/notifications_utlis.dart';
import '../../../../../utlis/string_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';
import '../../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../../../general_widgets/pickers/duration_picker.dart';
import '../../../../ui_manager.dart';
import '../../dialogs/send_notification_dialog.dart';
import 'widgets/duration_before_notification.dart';
import 'widgets/notification_switch.dart';
import 'widgets/notify_on_new_customer.dart';
import 'widgets/notify_when_ordering_switch.dart';

late BuildContext notificationContext;
List<Map<String, dynamic>> userSettings = [
  {
    "icon": Icon(Icons.notifications),
    "name": "notifications",
    "onClick": () => {},
    "suffix": NotificationSwitch()
  },
  {
    "icon": Icon(Icons.timelapse),
    "name": "timeBeforeNotify",
    "trailing": StringBeforeNotify(),
    "onClick": () async {
      DurationPicker durationPicker = DurationPicker(
          title: infoButton(
            context: notificationContext,
            text: translate("timeBeforeNotify"),
          ),
          initData: durationToMap(Duration(
              minutes: notificationContext
                  .read<DeviceProvider>()
                  .minutesBeforeNotify)));

      if (!notificationContext.read<DeviceProvider>().isAllowedNotification) {
        await activateNotificationDialog(notificationContext);
        if (notificationContext.read<DeviceProvider>().isAllowedNotification) {
          UiManager.updateUi(context: notificationContext);
        }
      }

      if (notificationContext.read<DeviceProvider>().isAllowedNotification) {
        await durationPicker.showPickerModal(notificationContext);
      }
      if (notificationContext.read<DeviceProvider>().isAllowedNotification) {
        final resultMinutes = mapToDuration(durationPicker.data).inMinutes;
        if (resultMinutes !=
            notificationContext.read<DeviceProvider>().minutesBeforeNotify) {
          notificationContext.read<DeviceProvider>().updateDurationBeforeNotify(
              newMinutesBeforeNotify: resultMinutes,
              context: notificationContext);
          deleteAllNotifications();
          bringBackAllNotifications(
            notificationContext.read<DeviceProvider>().isAllowedNotification,
            notificationContext.read<DeviceProvider>().minutesBeforeNotify,
          );
        } else {
          CustomToast(context: notificationContext, msg: translate("sameData"))
              .init();
        }
      }
    }
  },
];

List<Map<String, dynamic>> workerSettings = [
  {
    "icon": Icon(Icons.notification_add),
    "name": "getNotifyWhenBooking",
    "onClick": () => {},
    "suffix": NotifyWhileOrderingSwitch()
  },
  {
    "icon": Icon(Icons.notification_add),
    "name": "getNotifyOnWaitingList",
    "onClick": () => {},
    "suffix": NotifyOnWaitingLiastEventsSwitch()
  },
];

List<Map<String, dynamic>> managerSettings = [
  {
    "icon": Icon(Icons.notifications_active),
    "name": "clientsNotifications",
    "onClick": () async {
      String? msg = await sendNotificationDialog(notificationContext);
      if (msg != null && msg.length >= 5) {
        ManagerProvider managerProvider =
            notificationContext.read<ManagerProvider>();
        String buisnessId = SettingsData.appCollection;
        String buisnessName = SettingsData.settings.shopName;
        Loading(
                navigator: Navigator.of(notificationContext),
                context: notificationContext,
                future: managerProvider.sendGeneralNotification(
                    msg: msg, buisnessId: buisnessId, title: buisnessName),
                msg: translate("sendSuccess"),
                animation: successAnimation)
            .dialog();
      }
    }
  },
  {
    "icon": Icon(Icons.notification_add),
    "name": "notifyOnNewCustomer",
    "onClick": () => {},
    "suffix": NotifyOnNewCustomer()
  },
];
