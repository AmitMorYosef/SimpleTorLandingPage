import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:management_system_app/services/in_app_services.dart/app_launcher.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/platform.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../general_widgets/buttons/custome_add_button.dart';
import '../../../general_widgets/intro/lib/flutter_intro.dart';
import '../../../helpers/fonts_helper.dart';
import '../../settings_page/pages/app_details.dart';

// ignore: must_be_immutable
class AppIcons extends StatelessWidget {
  final bool editMode;
  final double? maxWidth;
  final double ratio;
  final Intro? intro;
  AppIcons(
      {super.key,
      this.editMode = false,
      this.maxWidth,
      this.ratio = 1,
      this.intro});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: intro == null ? null : intro!.keys[2],
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? gWidth * 0.7 * ratio,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customIcon(
                      icon: FaIcon(FontAwesomeIcons.mapLocationDot,
                          size: 22 * ratio),
                      iconString: translate('navigate'),
                      context: context,
                      info: SettingsData.settings.adress,
                      onPressed: () async {
                        if (!await isNetworkConnected()) {
                          notNetworkConnectedToast(context);
                          return;
                        }
                        if (SettingsData.settings.adress == "") {
                          CustomToast(
                                  context: context, msg: translate("noAdress"))
                              .init();
                          return;
                        }
                        launchNavigate(context, SettingsData.settings.adress);
                      }),
                  customIcon(
                      icon:
                          FaIcon(FontAwesomeIcons.instagram, size: 22 * ratio),
                      iconString: translate('instagram'),
                      context: context,
                      info: SettingsData.settings.instagramAccount == ""
                          ? ""
                          : "@" + SettingsData.settings.instagramAccount,
                      onPressed: () async {
                        if (!await isNetworkConnected()) {
                          notNetworkConnectedToast(context);
                          return;
                        }
                        if (SettingsData.settings.instagramAccount == "") {
                          CustomToast(
                                  context: context,
                                  msg: translate("noInstagram"))
                              .init();
                          return;
                        }
                        AppLauncher().launchInstagram(
                            SettingsData.settings.instagramAccount);
                      }),
                  // customIcon(
                  //     icon: FaIcon(FontAwesomeIcons.tiktok, size: 25),
                  //     iconString: translate('tiktok'),
                  //     context: context,
                  //     info: SettingsData.settings.instagramAccount == ""
                  //         ? "g"
                  //         : "@" + SettingsData.settings.instagramAccount,
                  //     onPressed: () async {
                  //       if (!await isNetworkConnected()) {
                  //         notNetworkConnectedToast(context);
                  //         return;
                  //       }
                  //       // if (SettingsData.settings.instagramAccount == "") {
                  //       //   CustomToast(
                  //       //           context: context, msg: translate("noInstagram"))
                  //       //       .init();
                  //       //   return;
                  //       // }
                  //       AppLauncher.launchTikTok(
                  //           'tiktok://www.tiktok.com/bnetanyahu');
                  //     }),
                  customIcon(
                      icon: FaIcon(FontAwesomeIcons.squarePhone,
                          size: 22 * ratio),
                      info: SettingsData.settings.shopPhone,
                      context: context,
                      iconString: translate('call'),
                      onPressed: () {
                        if (SettingsData.settings.shopPhone == "") {
                          CustomToast(
                                  context: context,
                                  msg: translate("noShopPhoneNumber"))
                              .init();
                          return;
                        }
                        AppLauncher()
                            .makePhoneCall(SettingsData.settings.shopPhone);
                      }),
                  customIcon(
                      icon: FaIcon(FontAwesomeIcons.whatsapp, size: 22 * ratio),
                      info: SettingsData.settings.shopPhone,
                      context: context,
                      iconString: translate('message'),
                      onPressed: () {
                        if (SettingsData.settings.shopPhone == "") {
                          CustomToast(
                                  context: context,
                                  msg: translate("noShopPhoneNumber"))
                              .init();
                          return;
                        }
                        AppLauncher()
                            .launchWhatsapp(SettingsData.settings.shopPhone);
                      }),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10 * ratio),
          child: CustomeAddButton(
            showWidget: editMode && UserData.getPermission() == 2,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => AppDetails())),
          ),
        )
      ],
    );
  }

  Widget customIcon(
      {required Widget icon,
      required String iconString,
      onPressed,
      required String info,
      required BuildContext context}) {
    return Padding(
      padding: EdgeInsets.all(14.0 * ratio),
      child: Opacity(
        opacity: info == '' ? 0.5 : 1,
        child: Column(
          children: [
            GestureDetector(
              onTap: onPressed,
              child: icon,
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0 * ratio),
              child: Text(iconString,
                  style: FontsHelper().businessStyle(
                      currentStyle: TextStyle(fontSize: 10 * ratio))),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 8.0),
            //   child: Text(
            //     info,
            //     style:
            //         TextStyle(color: Theme.of(context).colorScheme.secondary),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

void launchNavigate(BuildContext context, String adress) {
  List<BottomSheetAction> actions = [
    BottomSheetAction(
      onPressed: (_) {
        AppLauncher().launchWaze(adress);
      },
      title: Text(
        'Waze',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.normal),
      ),
    ),
    BottomSheetAction(
      onPressed: (_) {
        AppLauncher().launchPlatformAppMaps(adress);
        //Navigator.pop(context);
      },
      title: Text(
        isWeb
            ? "Maps"
            : Platform.isIOS
                ? "Apple Maps"
                : "Google Maps",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.normal),
      ),
    ),
  ];
  if (!isWeb && Platform.isIOS)
    actions.add(BottomSheetAction(
      onPressed: (context) {
        AppLauncher().launchGoogleMaps(adress);
      },
      title: Text(
        'Google Maps',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.normal),
      ),
    ));
  showAdaptiveActionSheet(
    title: Text(translate("chooseApp"),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14)),
    context: context,
    actions: actions,
    cancelAction: CancelAction(
      onPressed: (_) {
        Navigator.pop(context);
      },
      title: Text(
        translate("cancel"),
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
