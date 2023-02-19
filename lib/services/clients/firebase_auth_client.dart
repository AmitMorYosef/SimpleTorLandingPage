import 'package:flutter/cupertino.dart';

import '../../app_const/application_general.dart';
import '../external_services/auth_service.dart';

class FirebaseAuthClient {
  static final FirebaseAuthClient _singleton = FirebaseAuthClient._internal();

  FirebaseAuthClient._internal();

  factory FirebaseAuthClient() {
    FirebaseAuthClient object = _singleton;
    return object;
  }
  AuthClass authClass = AuthClass();

  Future<bool> loginAnonymously() async {
    return await authClass.loginAnonymously();
  }

  bool isLoggedInAnonymously() {
    return false;
  }

  Future<bool> loginWithPhone({required BuildContext context}) async {
    return await authClass.loginWithPhone(context);
  }

  Future<bool> verifyOTP({required BuildContext context}) async {
    return await authClass.verifyOTP(context);
  }

  Future<bool> logout() async {
    return await authClass.logout();
  }

  bool isLoggedIn() {
    return authClass.isLoggedIn();
  }

  bool userConnectedOnlyLocally() {
    return authClass.userConnectedOnlyLocally();
  }

  Future<bool> updateUserNameLocally(
      {required String name, required String phonePrefix}) async {
    try {
      await authClass.updateUserName(name, phonePrefix);
      return true;
    } catch (e) {
      logger.e("Error accured while sane user name --> $e");
      return false;
    }
  }

  String getUserPhone() {
    if (authClass.user != null) {
      logger.d("auth user --> ${authClass.user}");
      String userNameData = authClass.user!.displayName!;
      String prefix = userNameData.split("&&")[1]; // name&&+972
      String phone =
          authClass.user!.phoneNumber!.replaceFirst(prefix, "$prefix-");

      // if (phone.length > 10) phone = phone.substring(1);
      return phone;
    }
    return '';
  }

  Map<String, String> getAnonymousInfo() {
    if (authClass.user != null && authClass.user!.displayName != null) {
      logger.d("auth user --> ${authClass.user}");
      String savedName = authClass.user!.displayName!;
      if (!savedName.contains('^@^'))
        return {"name": '', "phone": '', 'anonymousDocId': ''};
      List<String> data = savedName.split('^@^');
      return {"name": data[0], "phone": data[1], 'anonymousDocId': data[2]};
    }
    return {};
  }

  Future<void> updateAnonymousInfo(
      {required String name,
      required String phone,
      required String docId}) async {
    return authClass.updateAnonymousInfo(
        name: name, phone: phone, docId: docId);
  }
}
