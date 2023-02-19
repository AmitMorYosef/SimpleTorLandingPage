import 'dart:io' show InternetAddress, Platform, SocketException;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iso_duration_parser/iso_duration_parser.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/login_provider.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../app_const/display.dart';
import '../app_const/operations.dart';
import '../app_const/platform.dart';
import '../app_const/purchases.dart';
import '../app_statics.dart/general_data.dart';
import '../app_statics.dart/screens_data.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/theme_data.dart';
import '../app_statics.dart/user_data.dart';

// ------------------------- genral functions ----------------------

void vibrate({int miliseconds = 150, int amplitude = 256}) async {
  bool hasVibration = await Vibration.hasVibrator() ?? false;
  //bool controlAbility = await Vibration.hasAmplitudeControl() ?? false;

  if (hasVibration)
    Vibration.vibrate(duration: miliseconds, amplitude: amplitude);
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

Future<bool> isTimeUpdated() async {
  try {
    if (isWeb) {
      return true;
    } else {
      DateTime _myTime;
      DateTime _ntpTime;

      /// Or you could get NTP current (It will call DateTime.now() and add NTP offset to it)
      _myTime = DateTime.now();

      /// Or get NTP offset (in milliseconds) and add it yourself
      final int offset = await NTP
          .getNtpOffset(
            localTime: _myTime,
            lookUpAddress: "time.google.com",
          )
          .timeout(Duration(seconds: 5), onTimeout: () => 0);

      _ntpTime = _myTime.add(Duration(milliseconds: offset));
      final dif = _myTime.difference(_ntpTime).inMilliseconds;
      logger.d('==== time.google.com ====');
      logger.d('My time: $_myTime');
      logger.d('NTP time: $_ntpTime');
      logger.d('Difference: ${dif}ms');
      return (dif.abs()) < 60000;
    }
  } catch (e) {
    logger.e("Times Error --> $e");
    AppErrors.addError(details: e.toString());
    return true;
  }
}

Future<bool> isNetworkConnected() async {
  if (isWeb) return true;
  bool isOnline = false;
  try {
    final result = await InternetAddress.lookup('example.com');
    isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    isOnline = false;
  }
  return isOnline;
}

Duration isoDurationToDuration(IsoDuration iso) {
  return Duration(
      days: (iso.days + (iso.weeks * 7) + (iso.months * 30) + (iso.years * 365))
          .round());
}

SubType subTypeFromProductId(String productId, String businessId) {
  if (productId.contains("basic")) {
    return SubType.basic;
  } else if (productId.contains("advanced")) {
    return SubType.advanced;
  } else if (productId == "") {
    final ownerPhone = businessId.split("--")[0];
    if (SettingsData.developers.contains(ownerPhone))
      return SubType.advanced;
    else
      return SubType.trial;
  }
  return SubType.trial;
}

//---------------------------- toast -----------------------

void notConnectedToast(BuildContext context) {
  CustomToast(
          context: context,
          msg: translate("youMustLogInFisrt"),
          gravity: ToastGravity.BOTTOM)
      .init();
}

void funcNotAvailableManagerToast(BuildContext context) {
  CustomToast(
          context: context,
          msg: translate("thisFuncNotAvailableOnBasicBusiness"),
          gravity: ToastGravity.BOTTOM)
      .init();
}

void funcNotAvailableClientToast(BuildContext context) {
  CustomToast(
          context: context,
          msg: translate("thisFuncNotAvailableOnThisBusiness"),
          gravity: ToastGravity.BOTTOM)
      .init();
}

void notNetworkConnectedToast(BuildContext context) {
  CustomToast(
          context: context,
          msg: translate("noInternetConnection"),
          gravity: ToastGravity.BOTTOM)
      .init();
}

void webAccessToImageToast(BuildContext context) {
  CustomToast(
          context: context,
          msg: translate("cantUploadNetworkImages"),
          gravity: ToastGravity.BOTTOM)
      .init();
}

void expiredSubToast(BuildContext context) async {
  CustomToast(
          context: context,
          msg: translate('expiredBusiness'),
          toastLength: Duration(milliseconds: 600),
          gravity: ToastGravity.BOTTOM)
      .init();
}

void reload_app(
    BuildContext context, bool openBookingSheet, bool openCreateBusiness) {
  if (openBookingSheet) {
    ScreensData.setOperation(Operations.openBookingSheet);
  }
  if (openCreateBusiness) {
    ScreensData.screenIndex = 0;
    ScreensData.setOperation(Operations.creatBusiness);
  }
  /* 
  this called after loggin/sign up to force the app load the new data
  call this function in settings utilis to prevent ancestor problems
  */
  // clean the memory and reset the loggin for new loggin
  context.read<LogginProvider>().setupLoggin();
  UiManager.cleanQueue();
  // update te main for re-build
  UiManager.updateUi(
      perform: Future(
    () => GeneralData.generalContext!
        .read<LogginProvider>()
        .updatefinishLogIn(true),
  ));
  UserData.userListinerAllowUpdate = true;
}

// app locals
Locale getLocal(String language) {
  Locale locale = const Locale("he", "IL");
  switch (language) {
    case "en":
      {
        locale = const Locale("en", "US");
      }
      break;
    case "he":
      {
        locale = const Locale("he", "IL");
      }
      break;
  }
  return locale;
}

// -------------------- screen handling -------------------

Future<void> overLaysHandling() async {
  if (isWeb) return;
  SystemUiOverlayStyle? style;
  Brightness brightness = themes[AppThemeData.defaultTheme]!.brightness;
  if (themes[AppThemeData.currentKeyTheme] != null) {
    brightness = themes[AppThemeData.currentKeyTheme]!.brightness;
  }

  style = brightness == Brightness.light
      ? SystemUiOverlayStyle.dark
      : SystemUiOverlayStyle.light;
  if (Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
  } else if (Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(style);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }
}

void preventRotate() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

List<dynamic> reverseList(List<dynamic> list, bool needToReverse) {
  return needToReverse ? list.reversed.toList() : list;
}
