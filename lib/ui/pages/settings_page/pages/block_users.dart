import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/providers/manager_provider.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../services/in_app_services.dart/app_launcher.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../general_widgets/buttons/info_button.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';

// ignore: must_be_immutable
class BlockUsers extends StatelessWidget {
  BlockUsers({super.key});

  TextEditingController titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          infoButton(context: context, text: translate("hereYouCanBlockUser")),
        ],
        elevation: 0,
        title: Text(translate("blockUsers")),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            SettingsData.settings.blockedUsers.length == 0
                ? Expanded(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: gWidth * .95,
                        child: Text(
                          translate("EmplyBlockUsersText"),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Lottie.asset(scurityAnimation, height: gHeight * 0.43),
                    ],
                  ))
                : Expanded(
                    child: SizedBox(
                      width: gWidth * .9,
                      child: ListView.builder(
                          itemCount: SettingsData.settings.blockedUsers.length,
                          itemBuilder: ((context, index) {
                            final details = SettingsData
                                .settings.blockedUsers.values
                                .elementAt(index);
                            final userPhone = SettingsData
                                .settings.blockedUsers.keys
                                .elementAt(index);
                            return userItem(userPhone, details, context);
                          })),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      bool? resp = await addDialog(context);
                      if (resp == true) {
                        await Loading(
                                context: context,
                                navigator: Navigator.of(context),
                                future: ManagerProvider.blockUser(
                                    userId: PickPhoneNumber.completePhone),
                                msg: translate("blockSuccessfully"))
                            .dialog();
                      }
                    },
                    icon: Icon(
                      Icons.add,
                    ),
                    iconSize: 40,
                  ),
                  Text(
                    translate("addUser"),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget userItem(String userPhone, String details, BuildContext context) {
    final splitedDatails = details.split("~");
    final dateString = splitedDatails[0];
    final gender = genderFromStr[splitedDatails[1]];
    final name = splitedDatails[2];
    return CustomContainer(
      width: double.infinity,
      image: null,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      boxBorder: Border.all(width: 0, color: Color(0xFF4E4E61).withOpacity(.2)),
      color: Theme.of(context).colorScheme.tertiary,
      child: Stack(
        children: [
          Center(
            child: Text(dateString,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 14)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: showCircleCachedImage(
                        '',
                        gDiagnol * 0.04,
                        gender == Gender.female
                            ? defaultWomanImage
                            : defaultManImage),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle),
                      child: GestureDetector(
                        onTap: () {
                          AppLauncher().launchWhatsapp(userPhone);
                        },
                        child: Icon(
                          FontAwesomeIcons.whatsapp,
                          size: gDiagnol * 0.025,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )),
                  SizedBox(width: 10),
                  Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle),
                      child: BouncingWidget(
                        onPressed: () {
                          AppLauncher().makePhoneCall(userPhone);
                        },
                        child: Icon(
                          Icons.call,
                          size: gDiagnol * 0.02,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )),
                  SizedBox(width: 10),
                  Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle),
                      child: BouncingWidget(
                        onPressed: () async {
                          bool? resp = await removeBlockDialog(context, name);
                          if (resp == true) {
                            await Loading(
                                    context: context,
                                    navigator: Navigator.of(context),
                                    future: ManagerProvider.removeBlock(
                                        userId: userPhone),
                                    msg: translate("removeBlockSuccessfully"))
                                .dialog();
                          }
                        },
                        child: Icon(
                          Icons.remove,
                          size: gDiagnol * 0.02,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> addDialog(BuildContext context) async {
    return await genralDialog(
      context: context,
      title: translate("block"),
      content: SizedBox(width: gWidth, child: PickPhoneNumber(showFlag: false)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(translate("cancel")),
        ),
        TextButton(
          onPressed: () {
            if (!PickPhoneNumber.validPhone) return;
            Navigator.pop(context, true);
          },
          child: Text(translate("save")),
        ),
      ],
    );
  }

  Future<bool?> removeBlockDialog(BuildContext context, String name) async {
    return await genralDialog(
      context: context,
      title: translate("removeBlock"),
      content: Text(
        translate("remove") + " $name " + translate("fromBlock") + "?",
        textAlign: TextAlign.center,
      ),
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
}
