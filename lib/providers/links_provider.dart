import 'dart:async';

import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/loading_provider.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import '../app_const/loading_statuses.dart';
import '../app_const/platform.dart';

class LinksProvider extends ChangeNotifier {
  bool appFirstTime = true;
  bool linkedHasChanged = false;
  late StreamSubscription sub;
  String linkedBuisnessId = '';

  Future<void> handleOpenAppLink() async {
    logger.i("AppFirstTime: $appFirstTime");
    try {
      if (appFirstTime) {
        appFirstTime = false;
        // first time - listening don't give link, have to take it myself
        String? link = await getInitialLink().timeout(
          Duration(seconds: 3),
          onTimeout: () => null,
        );
        logger.i("The link of the first time --> $link");
        if (link != null) {
          String buisnessId = getBuisnessId(link);
          if (buisnessId != '' && buisnessId != linkedBuisnessId) {
            linkedBuisnessId = buisnessId;
          }
        }
        // listen to link only for app -> not web
        if (!isWeb)
          sub = linkStream.listen((String? link) {
            logger.i("Uni link: " + link.toString());
            if (link != null) {
              String buisnessId = getBuisnessId(link);
              if (buisnessId != '' && buisnessId != linkedBuisnessId) {
                linkedBuisnessId = buisnessId;
                linkedHasChanged = true;
              }
            }
          }, onError: (err) {
            logger.e("Error occured while listen to link --> $err");
          });
      }
    } catch (e) {
      logger.e("Link general error $e");
    }
  }

  Future<void> linksAfterResumeApp(BuildContext context) async {
    logger.i("LinkedHasChanged ---->  ${this.linkedHasChanged}");
    if (this.linkedHasChanged) {
      logger.d("Link update screen");
      this.linkedHasChanged = false;
      context.read<LoadingProvider>().status = LoadingStatuses.loading;
      UiManager.insertUpdate(Providers.links);
    }
  }

  String getBuisnessId(String initialLink) {
    // if (!initialLink.toLowerCase().contains("simpletor") &&
    //     !initialLink.contains(secondOptionslLink)) {
    //   logger.i("link is not related to the app --> $initialLink");
    //   return '';
    // }
    Uri link = Uri.parse(initialLink);
    logger.i("Query params --> ${link.queryParameters}");
    logger.i("Segments --> ${link.pathSegments}");
    // http://simpletor.officialsimplecode.com/BusinessId=123vfbld4
    String buisnesId = link.queryParameters["BusinessId"] ?? '';
    return buisnesId;
    // if (link.pathSegments.contains("buisnesses")) {

    // }
    // return '';
  }

  void updateScreen() => notifyListeners();
}
