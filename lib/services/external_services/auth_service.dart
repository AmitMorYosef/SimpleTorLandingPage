import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/login_provider.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/services/errors_service/messages.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:provider/provider.dart';

import '../../../app_const/resources.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../ui/general_widgets/loading_widgets/loading_dialog.dart';
import '../../../ui/ui_manager.dart';
import '../../../utlis/string_utlis.dart';
import '../../providers/user_provider.dart';

class AuthClass {
  User? user;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> useEmulator() async {
    await auth.useAuthEmulator("http://127.0.0.1/", 9099);
  }

  Future<UserCredential> authWithApple() async {
    return await auth.signInWithProvider(AppleAuthProvider());
  }

  Future<UserCredential> authWithGitHub() async {
    return await auth.signInWithProvider(GithubAuthProvider());
  }

  Future<UserCredential> authWithGoogle() async {
    return await auth.signInWithProvider(GoogleAuthProvider());
  }

  bool isLoggedIn() {
    user = auth.currentUser;

    return user != null && user!.phoneNumber != null && !user!.isAnonymous;
  }

  bool isLoggedInAnonymously() {
    user = auth.currentUser;
    return user != null && user!.isAnonymous;
  }

  Future<void> updateAnonymousInfo(
      {required String name,
      required String phone,
      required String docId}) async {
    try {
      await auth.currentUser!.updateDisplayName("$name^@^$phone^@^$docId");
      user = auth.currentUser;
    } catch (e) {
      AppErrors.addError(
          error: Errors.updateDisplayName, details: e.toString());
      throw (e);
    }
  }

  Future<void> updateUserName(String name, String phonePrefix) async {
    try {
      await user!.updateDisplayName("$name&&$phonePrefix");

      await user!.reload();
      user = await auth.currentUser;
    } catch (e) {
      AppErrors.addError(
          error: Errors.updateDisplayName, details: e.toString());
      throw (e);
    }
  }

  bool userConnectedOnlyLocally() {
    /* this function shuden't work on manager coused it temporarily user 
    so the signUp procces can't stop in the middle */
    // the diaplay name updating only after finish sign up
    return isLoggedIn() && user!.displayName == null;
  }

  Future<bool> loginAnonymously() async {
    if (auth.currentUser != null) return true;
    logger.d("Starting log-in anonymously");
    try {
      await auth.signInAnonymously().then((userCredential) {
        user = auth.currentUser;
      });
      return user != null;
    } catch (e) {
      logger.e("it was an error while sign in anonymously the error is --> $e");
      AppErrors.error = Errors.anonymouslySignIn;
      if ("$e".contains("network error")) AppErrors.error = Errors.network;
      AppErrors.details = e.toString();
      return false;
    }
  }

  Future<bool> loginWithPhone(BuildContext context) async {
    LogginProvider loggin = context.read<LogginProvider>();

    bool response = false;
    await auth.verifyPhoneNumber(
      phoneNumber: "${PickPhoneNumber.completePhone}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // new android devices - able to auto get sms code
        await Loading(
                desplayErrorDetails: true,
                displayErrorDuration: Duration(seconds: 3),
                navigator: Navigator.of(context),
                isBoolCondition: true,
                context: context,
                msg: translate('authenticationCompleted'),
                future: verifyAndTryToLoadUser(
                    context, credential, loggin), //tryLogin(),
                animation: successAnimation)
            .dialog()
            .then((value) async {
          if (value == true) {
            bool userExistInDb = UserData.user.phoneNumber != '';
            if (!userExistInDb) {
              // close the sheet and open sign up sheet
              Navigator.pop(context, "SIGN_UP");
            } else {
              Navigator.pop(context, "LOGED_IN");
            }
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        AppErrors.addError(error: Errors.sendSms, details: e.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        response = true;
        loggin.verificationID = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return response;
  }

  Future<bool> verifyOTP(BuildContext context,
      {PhoneAuthCredential? autocredential}) async {
    LogginProvider loggin = context.read<LogginProvider>();
    PhoneAuthCredential credential = autocredential ??
        PhoneAuthProvider.credential(
            verificationId: loggin.verificationID, smsCode: loggin.opt);
    try {
      await auth.signInWithCredential(credential).then(
        (value) {
          value.user;
          user = auth.currentUser;
        },
      );
      if (user == null) {
        logger.e("Unknown verification error");
        AppErrors.addError(error: Errors.unknown, details: 'Unknown error');
        return false;
      }
      return true;
    } on FirebaseAuthException catch (e) {
      logger.e("it was an error the error is --> $e");
      logger.e(e.code);
      AppErrors.details = e.message ?? e.code;
      switch (e.code) {
        case 'invalid-verification-code':
          AppErrors.error = Errors.wrongOptCode;
          return false;
        case 'invalid-verification-id':
          AppErrors.error = Errors.verification;
          return false;
        case 'invalid-credential':
          AppErrors.error = Errors.expiredOpt;
          return false;
        default:
          AppErrors.error = Errors.unknown;
          return false;
      }
    } catch (e) {
      logger.e("it was an error the error is --> $e");
      AppErrors.error = Errors.serverError;
      if ("$e".contains("network error")) AppErrors.error = Errors.network;
      AppErrors.details = e.toString();
      return false;
    }
  }

  Future<bool> logout() async {
    bool response = false;
    try {
      await auth.signOut().then((value) async {
        response = true;
      });
    } catch (e) {
      AppErrors.addError(error: Errors.logout, details: e.toString());
    }
    return response;
  }

  Future<bool> verifyAndTryToLoadUser(BuildContext context,
      PhoneAuthCredential? credential, LogginProvider loggin) async {
    bool isVerified = await verifyOTP(context, autocredential: credential);
    if (!isVerified) {
      // validation error
      return false;
    }
    await context.read<UserProvider>().setupUser(
        phone: PickPhoneNumber.completePhone,
        logoutIfDosentExist: false); // setup the logged it user
    UiManager.cleanQueue();
    return isVerified;
  }
}
