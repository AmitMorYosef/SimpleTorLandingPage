/// This file is used to hold data about the user that
/// every file can access to
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_tor_web/app_statics.dart/settings_data.dart';
import 'package:simple_tor_web/services/clients/firebase_auth_client.dart';

import '../app_const/application_general.dart';
import '../app_const/db.dart';
import '../models/user_model.dart';
import '../services/clients/firestore_client.dart';
import '../services/clients/server_notifications_client.dart';
import '../services/errors_service/app_errors.dart';
import '../services/errors_service/messages.dart';
import '../services/errors_service/user.dart';
import '../ui/ui_manager.dart';
import 'general_data.dart';

class UserData {
  static bool userListinerAllowUpdate =
      false; // only after finish loading app true in pagesManager
  static DocumentSnapshot<Map<String, dynamic>>? userDoc;
  static User user = User(
    name: "guest",
    myBuisnessesIds: [],
    productsIds: {},
    lastVisitedBuisnessesRemoved: [],
    lastVisitedBuisnesses: [],
    subToNotifications: {},
  ); // hold the current user
  static String currentBuisness =
      ''; // the curren buisness that in buisness page
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      userPublicDataListener;
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      userDocListener;

  static bool showCurrentBookings = true;

  // ---------------------------------- listeners -----------------------------

  static void startPublicDataListening() {
    /*create listening for the user public data */
    if (!isConnected()) return;
    final docListener = FirestoreClient().docListener(
        path: "$usersCollection/${UserData.user.phoneNumber}/$dataCollection",
        docId: dataDoc);
    UserData.userPublicDataListener = docListener.listen((dataJson) {
      if (dataJson.exists) {
        UserData.user.setUserPublicData(dataJson.data()!);
        logger.d("Geting new user data from data base ");
        UiManager.insertUpdate(Providers.user);
        if (UserData.userListinerAllowUpdate) {
          UiManager.updateUi(context: GeneralData.generalContext);
        }
      }
    });
  }

  static Future<void> cancelPublicDataListening() async {
    /*cancel current user listening */
    try {
      await UserData.userPublicDataListener!.cancel();
      logger.d("User Listening canceled");
    } catch (e) {
      AppErrors.addError(
          code: userCodeToInt[UserErrorCodes.cancelListening],
          error: Errors.listener,
          details: e.toString());
      logger.d("Error while pausing the user lisntner --> $e");
    }
  }

  // --
  static bool isConnected() {
    //AppErrors.addError(code: userCodeToInt[UserErrorCodes.isConnected]);
    return FirebaseAuthClient().isLoggedIn();
  }

  // ---------------------------------- expired data ----------------------------

  // --
  static int getPermission() {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.getPermission]);
    if (!isConnected()) return 0;

    if (UserData.user.permission.keys.contains(UserData.currentBuisness))
      return UserData.user.permission[UserData.currentBuisness]!;
    else {
      return 0;
    }
  }

  // --
  static bool isDevloper() {
    if (!isConnected()) return false;
    return SettingsData.developers
        .contains(UserData.user.phoneNumber.replaceAll("+", ""));
  }

  static Future<void> notifyCanceledBooking(String topic) async {
    AppErrors.addError(
        code: userCodeToInt[UserErrorCodes.notifyCanceledBooking]);
    await ServerNotificationsClient().notifyCanceldBooking(topic: topic);
  }
}
