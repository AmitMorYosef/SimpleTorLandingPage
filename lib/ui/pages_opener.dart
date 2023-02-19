import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/ui/pages/login_page/login.dart';
import 'package:simple_tor_web/ui/pages/login_page/sign_up.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';

import '../app_statics.dart/user_data.dart';
import '../providers/login_provider.dart';
import '../providers/user_provider.dart';
import '../utlis/general_utlis.dart';
import 'general_widgets/custom_widgets/sliding_bottom_sheet.dart';

class PagesOpener {
  Future<void> openLogin(
      {required BuildContext context,
      bool openBookingSheet = false,
      bool openCreateBusiness = false}) async {
    UserData.userListinerAllowUpdate = false; // prevent ancestor
    //  ScreensData.screenIndex = 1;
    dynamic resp = await SlidingBottomSheet(
            context: context, sheet: LoginScreen(), size: 1)
        .showSheet();
    if (resp == 'SIGN_UP') {
      dynamic signUpResp =
          await SlidingBottomSheet(context: context, sheet: SignUp(), size: 1)
              .showSheet();
      if (signUpResp == 'SUCSSES') {
        reload_app(context, openBookingSheet,
            openCreateBusiness); // return userListinerAllowUpdate to allow updates
        return;
      } else {
        logger.e("Sign-up error the resp was -> $signUpResp");
        // silently logg the user out - no need dialog. intended to fix error
        UiManager.updateUi(
            context: context, perform: context.read<UserProvider>().logout());
      }
    } else if (resp == 'LOGED_IN') {
      reload_app(context, openBookingSheet,
          openCreateBusiness); // return userListinerAllowUpdate to allow updates
      return;
    }
    logger.d('Clean the login for new one, resp was - $resp');
    // clean the memory and reset the loggin for new loggin
    context.read<LogginProvider>().setupLoggin();
    UserData.userListinerAllowUpdate = true; // return it to allow updates
    return;
  }
}
