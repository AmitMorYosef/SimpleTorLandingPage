import 'package:flutter/material.dart';
import 'package:management_system_app/ui/ui_manager.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/screens_data.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../utlis/string_utlis.dart';
import '../../../general_widgets/dialogs/genral_dialog.dart';

Widget backButton(BuildContext context) {
  return SafeArea(
    child: GestureDetector(
      onTap: () async {
        UiManager.updateUi(
            context: context, perform: removeCurrentBuisness(context));
        // await makeSureExitDialog(context).then((value) {
        //   if (value == true) {
        //     UiManager.updateUi(
        //         context: context, perform: removeCurrentBuisness(context));
        //   }
        // });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          width: 35,
          height: 35,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.background),
          child: Icon(
            Icons.exit_to_app,
            color: Theme.of(context).colorScheme.secondary,
            size: 25,
          ),
        ),
      ),
    ),
  );
}

Future<void> removeCurrentBuisness(BuildContext context) async {
  ScreensData.initOffests();
  ScreensData.changingPhotoIndex = 0;
  SettingsData.emptyBusinessData();
}

Future<bool> makeSureExitDialog(BuildContext context) async {
  bool resp = false;
  await genralDialog(
    context: context,
    title: translate('areYouSure'),
    content: Container(
      alignment: Alignment.center,
      height: gHeight * .08,
      child: Text(
        translate('goToSearch') + '?',
        textAlign: TextAlign.center,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          resp = false;
          Navigator.pop(context);
        },
        child: Text(translate('no')),
      ),
      TextButton(
        onPressed: () async {
          await SettingsData.cancelWorkerListening();

          UiManager.updateUi(
              context: context,
              perform: Future((() => SettingsData.emptyBusinessData())));
          resp = true;
          Navigator.pop(context);
        },
        child: Text(translate('yes')),
      ),
    ],
  );
  return resp;
}
