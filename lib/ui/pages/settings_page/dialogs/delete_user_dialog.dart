import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:management_system_app/providers/manager_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../utlis/notifications_utlis.dart';

Future<dynamic> deleteUserDialog(BuildContext context) async {
  dynamic resp = await genralDialog(
    animationType: DialogTransitionType.slideFromTopFade,
    context: context,
    title: translate('deleteUser'),
    content: Column(
      children: [
        UserData.user.myBuisnessesIds.length > 0
            ? Text(
                translate('forDeleteUser1'),
                textAlign: TextAlign.center,
              )
            : SizedBox(),
        Text(
          translate('forDeleteUser2'),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20,
        ),
        PickPhoneNumber(
          showFlag: false,
          validate: validate,
          hintText: UserData.user.phoneNumber.split('-')[1],
        )
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: Text(translate('cancel')),
      ),
      TextButton(
        onPressed: () async {
          if (PickPhoneNumber.completePhone != UserData.user.phoneNumber) {
            return;
          }
          Navigator.pop(context, "OK");
        },
        child: Text(translate('continue')),
      ),
    ],
  );
  if (resp == 'OK') {
    await Loading(
            navigator: Navigator.of(context),
            context: context,
            future: deleteUser(context),
            timeOutDuration: Duration(seconds: 8),
            msg: translate('UserDeleted'),
            animation: deleteAnimation)
        .dialog();
  }
}

String validate() {
  if (UserData.user.phoneNumber != PickPhoneNumber.completePhone) {
    return translate("noMatchPhoneNumbers");
  }
  return '';
}

Future<bool> deleteUser(BuildContext context) async {
  ManagerProvider managerProvider = context.read<ManagerProvider>();

  await UserData.cancelPublicDataListening();

  //delete all the worker objects of me from all the buisnesses
  final premissions = [...UserData.user.permission.keys];
  await Future.forEach(premissions, (id) async {
    if (UserData.user.permission[id] == 1)
      await managerProvider.deleteWorker(UserData.user.phoneNumber, id, context,
          insideLoop: true);
  });

  //delete all my buisnesses
  final duplicate = [...UserData.user.myBuisnessesIds];
  await Future.forEach(duplicate, (id) async {
    // empty string sended beacuse user doc will be deleted
    await managerProvider.deleteBuisness(id, "", "", "");
  });

  // -------------------------------
  //await DeviceProvider.updateIsAllowedNotification(false);
  await deleteAllNotifications();
  await context.read<UserProvider>().deviceTurnOffNotifications();
  await context.read<UserProvider>().deleteUser(UserData.user);
  await context.read<UserProvider>().logout();
  return true;
}
