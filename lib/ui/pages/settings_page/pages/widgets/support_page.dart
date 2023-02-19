import 'dart:io';

import 'package:flutter/material.dart';
import 'package:management_system_app/services/in_app_services.dart/app_launcher.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../../app_const/app_external_links.dart';
import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/platform.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: gWidthOriginal,
      height: gHeight * .6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title(context),
          description(context),
          writeMessageTab(context),
        ],
      ),
    );
  }

  Widget title(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: gHeight * 0.01),
      child: Text(
        translate("Support"),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 22),
      ),
    );
  }

  Widget description(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: gHeight * .4),
      width: gWidth * .85,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              translate("SupportDscription"),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            // Icon(
            //   FontAwesomeIcons.message,
            //   size: 30,
            // )
          ],
        ),
      ),
    );
  }

  Widget writeMessageTab(BuildContext context) {
    return CustomContainer(
        onTap: () async {
          // android inApp webView makes issues with keyboard so - external web
          bool keybordIssue = !isWeb && Platform.isAndroid;
          await AppLauncher().launchApp(simpleCodeWebUrl, simpleCodeWebUrl,
              needUseKeybord: keybordIssue);
        },
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.only(bottom: gHeight * .03),
        padding: EdgeInsets.symmetric(vertical: 10),
        raduis: 999,
        alignment: Alignment.center,
        width: gWidth * .8,
        child: Text(
          translate("ContactUs"),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
        ));
  }
}
