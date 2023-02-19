import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utlis/notifications_utlis.dart';

Future<dynamic> logOutDialog(BuildContext context) async {
  dynamic resp = await genralDialog(
    animationType: DialogTransitionType.slideFromTopFade,
    context: context,
    title: translate("logout"),
    content: Text(
      translate("sureYouWantLogout"),
      textAlign: TextAlign.center,
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: Text(translate("no")),
      ),
      TextButton(
        onPressed: () async {
          // ScreensData.screenIndex = 1;
          Navigator.pop(context, "OK");
        },
        child: Text(translate("yes")),
      ),
    ],
  );
  if (resp == 'OK') {
    await Loading(
            navigator: Navigator.of(context),
            context: context,
            future: deleteData(context),
            msg: translate("logoutSuccessfully"),
            animation: successAnimation)
        .dialog();
  }
}

Future<bool> deleteData(BuildContext context) async {
  await SettingsData.cancelWorkerListening();
  //await DeviceProvider.updateIsAllowedNotification(false); -> leave this same
  await deleteAllNotifications();
  await context.read<UserProvider>().deviceTurnOffNotifications();
  await context.read<UserProvider>().logout();
  // context.read<LoadingProvider>().updateStatus(LoadingStatuses.loading);
  // context.read<LogginProvider>().updatefinishLogIn(false);
  return true;
}
