import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_system_app/services/clients/firestore_client.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app_const/application_general.dart';
import '../../app_const/db.dart';
import '../../app_const/platform.dart';
import '../../app_statics.dart/subscription_data.dart';
import '../../app_statics.dart/user_data.dart';
import '../../models/user_model.dart';

class PurchesesHelper {
  /// Get: ensure current user have all his entitlements avialble
  Future<void> subscriptionsInsurance() async {
    User user = UserData.user;
    /*Update the db with the available subscriptions from 
    the revenueCat server */
    if (isWeb) return;
    final activeSubs =
        await SubscriptionData.getActiveSubs(revenueCatId: user.revenueCatId);
    logger.d("User active subs Insurance --> $activeSubs");
    bool hasChange = false;
    Map<String, Map<String, dynamic>> data = {};
    /*Insure that user has all the subs that appears 
      in the revenueCat server */

    activeSubs.forEach((activeSub) {
      if (!user.productsIds.containsKey(activeSub)) {
        data[activeSub] = {
          "date": Timestamp.fromDate(DateTime.now()),
          "businessId": ""
        };
        hasChange = true;
      }
    });

    /*Insure that the user doesnt has expired subs*/
    user.productsIds.forEach((productId, details) {
      /*Determind if the sub is expired - add 5 minutes to 
        ensure that the sub  is updated in the revenueCat server 
        (usually they cache the active subs)*/
      if (details["date"] != null &&
              (details["date"] as Timestamp)
                  .toDate()
                  .isAfter(DateTime.now().add(Duration(minutes: 5))) ||
          activeSubs.contains(productId)) {
        data[productId] = details;
      } else {
        hasChange = true;
      }
    });

    if (!hasChange) return;

    /*There are changes and need to update users "productsIds" */
    user.productsIds = data;

    /* No need to wait */
    FirestoreClient().updateFieldInsideDocAsMap(
        path: usersCollection,
        docId: user.phoneNumber,
        fieldName: "productsIds",
        value: data);
  }

  /// Get: give the current user all the entitlements on the appleId / Gmail
  Future<bool> restorePurchases() async {
    User user = UserData.user;
    /* restore all the  purchases that ralated to this AppleId/Google gmail
    and give the new user all the subs that the previous user had */
    try {
      final info = await Purchases.restorePurchases();
      final activeSubs = info.activeSubscriptions;
      logger.d("Active transfer subs --> $activeSubs");
      Map<String, Map<String, dynamic>> data = {};
      activeSubs.forEach((sub) {
        data["productsIds.$sub"] = {
          "date": Timestamp.fromDate(DateTime.now()),
          "businessId": ""
        };
      });
      return await FirestoreClient()
          .updateMultipleFieldsInsideDocAsMap(
              path: usersCollection, docId: user.phoneNumber, data: data)
          .then(
        (value) {
          if (value) {
            activeSubs.forEach((sub) {
              user.productsIds[sub] = {
                "date": Timestamp.fromDate(DateTime.now()),
                "businessId": ""
              };
            });
            UiManager.insertUpdate(Providers.user);
          }
          return value;
        },
      );
    } catch (e) {
      logger.e("Error while restore purchases --> $e");
      return false;
    }
  }
}
