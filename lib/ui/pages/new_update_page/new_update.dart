import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_const/app_external_links.dart';
import '../../../app_const/app_sizes.dart';
import '../../../app_const/platform.dart';
import '../../../app_const/resources.dart';
import '../../animations/enter_animation.dart';
import '../../general_widgets/buttons/change_lang_button.dart';

class NewUpdate extends StatelessWidget {
  const NewUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            Positioned(
              child: ChangeLangButton(),
              top: 40,
              right: 20,
            ),
            Container(
              padding: EdgeInsets.only(top: gHeight * 0.1),
              width: gWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(rocketAnimation, height: gHeight * 0.43),
                  SizedBox(
                    height: gHeight * .05,
                  ),
                  SizedBox(
                    width: gWidth * .9,
                    height: gHeight * .42,
                    child: EnterAnimation(
                      animationDuration: Duration(milliseconds: 800),
                      childCreator: detailsColumn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget detailsColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          translate("updateTitle"),
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 24),
        ),
        SizedBox(
          height: 15,
        ),
        SizedBox(
          width: gWidth * .8,
          child: Text(
            translate("updateInfo"),
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        updateButton(context)
      ],
    );
  }

  Widget updateButton(BuildContext context) {
    return CustomContainer(
      onTap: () async {
        if (isWeb) return;
        bool launched = false;
        if (Platform.isIOS) {
          launched = await launchUrl(Uri.parse(iosPhoneDownloadLink));
        } else {
          launched = await launchUrl(Uri.parse(androidPhoneDownloadLink));
        }
        if (!launched) {
          CustomToast(
                  context: context,
                  msg: translate("strName"),
                  gravity: ToastGravity.CENTER)
              .init();
        }
      },
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 12),
      margin: EdgeInsets.only(bottom: 40),
      raduis: 999,
      width: gWidth * .88,
      child: Text(
        translate("update"),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18),
      ),
    );
  }
}
