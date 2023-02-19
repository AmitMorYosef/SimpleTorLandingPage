import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/services/clients/firebase_auth_client.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/services/errors_service/login.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/ui/ui_manager.dart';

class LogginProvider extends ChangeNotifier {
  String verificationID = ""; // hold the id of the firebase verification
  String opt = ""; // hold the user input opt
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String submitedPhone = '';
  bool finishLogIn = false; // is user finish the loggin yet or not
  bool confirmedPolicy = false;
  Country currentCountry = Country(
    code: 'IL',
    name: 'Israel',
    dialCode: '972',
    flag: '🇮🇱',
    maxLength: 9,
    minLength: 9,
  );

  void updatefinishLogIn(bool val) {
    AppErrors.addError(code: loginCodeToInt[LoginErrorCodes.updatefinishLogIn]);
    this.finishLogIn = val;
    UiManager.insertUpdate(Providers.settings); // update the pages manager
  }

  void logoutIfSignUpNotCompleted() async {
    AppErrors.addError(
        code: loginCodeToInt[LoginErrorCodes.logoutIfSignUpNotCompleted]);
    if (FirebaseAuthClient().userConnectedOnlyLocally()) {
      logger.i("Log the user out because sign up wasn't completed.. ");
      await FirebaseAuthClient().logout();
      UiManager.insertUpdate(Providers.login);
    }
  }

  bool userLoggedIn() {
    AppErrors.addError(code: loginCodeToInt[LoginErrorCodes.userLoggedIn]);
    return FirebaseAuthClient().isLoggedIn();
  }

  Future<bool> saveUserNameLocally(
      {required String name, required String phonePrefix}) async {
    return await FirebaseAuthClient()
        .updateUserNameLocally(name: name, phonePrefix: phonePrefix);
  }

  void setupLoggin() {
    AppErrors.addError(code: loginCodeToInt[LoginErrorCodes.setupLoggin]);
    confirmedPolicy = false;
    this.verificationID = '';
    this.submitedPhone = '';
    this.phoneController = TextEditingController();
    this.userNameController = TextEditingController();
  }

  Future<bool> verifyOpt(BuildContext context) async {
    AppErrors.addError(code: loginCodeToInt[LoginErrorCodes.verifyOpt]);
    return await FirebaseAuthClient().verifyOTP(context: context);
  }

  Future<bool> sendSmsToPhone(BuildContext context) async {
    this.submitedPhone = PickPhoneNumber.completePhone;
    AppErrors.addError(code: loginCodeToInt[LoginErrorCodes.sendSmsToPhone]);
    return await FirebaseAuthClient().loginWithPhone(context: context);
  }

  Future<bool> logginAnonimously() async {
    AppErrors.addError(code: loginCodeToInt[LoginErrorCodes.logginAnonimously]);
    return await FirebaseAuthClient().loginAnonymously();
  }

  void updateScreen() => notifyListeners();
}
