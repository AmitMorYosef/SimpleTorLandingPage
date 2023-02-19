import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../providers/manager_provider.dart';
import '../../../general_widgets/dialogs/genral_dialog.dart';
import '../../../general_widgets/loading_widgets/loading_dialog.dart';

Future<dynamic> DeleteBuisnessDialog(BuildContext context) async {
  dynamic resp = await genralDialog(
    animationType: DialogTransitionType.slideFromTopFade,
    context: context,
    title: translate('buisnessDeletion'),
    content: Column(
      children: [
        Text(
          translate('ensureDeleteBusiness'),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 5,
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
        child: Text(translate('no')),
      ),
      TextButton(
        onPressed: () async {
          if (PickPhoneNumber.completePhone != UserData.user.phoneNumber) {
            return;
          }
          Navigator.pop(context, "OK");
        },
        child: Text(translate('yes')),
      ),
    ],
  );
  if (resp == 'OK') {
    await Loading(
            context: context,
            navigator: Navigator.of(context),
            future: context.read<ManagerProvider>().deleteBuisness(
                SettingsData.appCollection,
                SettingsData.settings.revenueCatId,
                SettingsData.settings.productId,
                SettingsData.settings.workersProductsId),
            msg: translate('businessDeleted'),
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
