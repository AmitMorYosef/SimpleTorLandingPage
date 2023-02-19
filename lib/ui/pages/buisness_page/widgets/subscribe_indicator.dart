import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/providers/user_provider.dart';
import 'package:simple_tor_web/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:simple_tor_web/ui/general_widgets/loading_widgets/loading_button.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../../app_const/notification.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/notification_topic.dart';
import '../../../../providers/device_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../animations/rotate_animation.dart';

// ignore: must_be_immutable
class SubscribeIndicator extends StatelessWidget {
  SubscribeIndicator({super.key});

  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = context.watch<UserProvider>();
    LoadingButton checkWidget = LoadingButton(
      key: UniqueKey(),
      startState: isSub() ? subIndicator(context) : unSubIndicator(context),
      middleState: loadingIndicator(context),
    );

    return GestureDetector(
        onTap: () async {
          if (checkWidget.isNowLoading) return;

          if (!UserData.isConnected()) {
            notConnectedToast(context);
            return;
          }

          if (!context.read<DeviceProvider>().isAllowedNotification &&
              !isSub()) {
            await genralDialog(
                context: context,
                title: translate("allowedNotificationsTitle"),
                content: Center(
                    child: Text(
                  translate("doYouWantToActiveateNotification"),
                  textAlign: TextAlign.center,
                )),
                actions: [
                  TextButton(
                      onPressed: (() => Navigator.pop(context)),
                      child: Text(translate("no"))),
                  TextButton(
                      onPressed: (() {
                        //changeAllowNotificationsStatus(context, true);
                        Navigator.pop(context);
                      }),
                      child: Text(translate("yes"))),
                ]);
            if (!context.read<DeviceProvider>().isAllowedNotification) {
              // didn't give permission
              return;
            }
          }
          checkWidget.load!(
              startState:
                  isSub() ? subIndicator(context) : unSubIndicator(context),
              endState:
                  isSub() ? unSubIndicator(context) : subIndicator(context),
              future: () async {
                return true;
              }

              // isSub()
              //     ? userProvider.unSubNotification(
              //         topicId: NotificationTopic(
              //           imageUrl: SettingsData.settings.shopIconUrl,
              //           businessName: SettingsData.settings.shopName,
              //           businessId: SettingsData.appCollection,
              //         ).toTopicStr(),
              //         sort: NotifySorts.buisness)
              //     : userProvider.subToNotification(
              //         notificationTopicObject: NotificationTopic(
              //           imageUrl: SettingsData.settings.shopIconUrl,
              //           businessName: SettingsData.settings.shopName,
              //           businessId: SettingsData.appCollection,
              //         ),
              //         sort: NotifySorts.buisness),
              );
        },
        child: checkWidget);
  }

  bool isSub() {
    return userProvider.isAlreadySub(
        topicId: NotificationTopic(
          imageUrl: SettingsData.settings.shopIconUrl,
          businessName: SettingsData.settings.shopName,
          businessId: SettingsData.appCollection,
        ).toTopicStr(),
        sort: NotifySorts.buisness);
  }

  Widget subIndicator(BuildContext context) {
    return Icon(
      Icons.check_circle,
      color: Theme.of(context).colorScheme.secondary,
      size: 15,
      key: Key("sub"),
    );
  }

  Widget unSubIndicator(BuildContext context) {
    return Icon(
      Icons.circle_notifications,
      color: Theme.of(context).colorScheme.secondary,
      size: 15,
      key: Key("unSub"),
    );
  }

  Widget loadingIndicator(BuildContext context) {
    return RotateAnimation(
        child: Icon(
      Icons.change_circle,
      color: Theme.of(context).colorScheme.secondary,
      size: 15,
      key: Key("unSub"),
    ));
  }
}
