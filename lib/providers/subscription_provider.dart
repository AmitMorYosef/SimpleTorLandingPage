import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/app_const/db.dart';
import 'package:management_system_app/app_statics.dart/user_data.dart';
import 'package:management_system_app/services/clients/firestore_client.dart';
import 'package:management_system_app/services/clients/revenue_cat_subscriptions_client.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../app_const/platform.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/subscription_data.dart';
import '../services/errors_service/app_errors.dart';
import '../services/errors_service/purchase.dart';
import '../ui/ui_manager.dart';

class SubscriptionProvider extends ChangeNotifier {
  Future<bool> changePurchasePlan(
      {required String productId,
      required String oldProductId,
      required String revenueCatId}) async {
    if (isWeb) return false;
    try {
      //make sure the user connected
      await SubscriptionData.loginToUser(revenueCatId: revenueCatId);
      if (Platform.isAndroid) {
        //purchase the product
        await RevenueCatSubscriptionClient().purchaseProduct(
            productId: productId,
            upgradeInfo: UpgradeInfo(oldProductId,
                prorationMode: ProrationMode.immediateWithTimeProration));
      } else if (Platform.isIOS) {
        await RevenueCatSubscriptionClient()
            .purchaseProduct(productId: productId);
      } else {
        return false;
      }

      SubscriptionData.alreadyPurchasedSubs.add(productId);

      logger.d(
          "User change sub successfully from --> $oldProductId to --> $productId");
      SubscriptionData.hasPerrmision = true;
      UiManager.insertUpdate(Providers.purchase);
      return true;
    } catch (e) {
      logger.d("Upgrade Failed --> $e");
      return false;
    }
  }

  Future<bool> purchaseBusiness(
      {required String productId,
      required String revenueCatId,
      bool isNew = false}) async {
    AppErrors.addError(
        code: purchaseCodeToInt[PurchaseErrorCodes.purchaseBusiness]);

    try {
      if (revenueCatId == "") return false;
      //make sure the user connected
      await SubscriptionData.loginToUser(revenueCatId: revenueCatId);
      //purchase the product
      await RevenueCatSubscriptionClient()
          .purchaseProduct(productId: productId);
      SubscriptionData.availableProductId = productId;

      //Saves the customer's purchase immediately after - cant lose it
      if (isNew) {
        await FirestoreClient()
            .updateFieldInsideDocAsMap(
                path: usersCollection,
                docId: UserData.user.phoneNumber,
                fieldName: "productsIds.$productId",
                value: "")
            .then(
          (value) {
            if (value) {
              UserData.user.productsIds[productId] = {
                "date": Timestamp.fromDate(DateTime.now()),
                "businessId": ""
              };
              SubscriptionData.alreadyPurchasedSubs.add(productId);
            }
          },
        );
      }

      logger.d("User purchase sub successfully");
      SubscriptionData.hasPerrmision = true;

      UiManager.insertUpdate(Providers.purchase);
      return true;
    } catch (e) {
      logger.d("Parchase Failed --> $e");
      return false;
    }
  }

  Future<bool> purchaseWorker(
      {required String businessId,
      required String productId,
      required String userId}) async {
    AppErrors.addError(
        code: purchaseCodeToInt[PurchaseErrorCodes.purchaseWorker]);
    try {
      await RevenueCatSubscriptionClient()
          .purchaseProduct(productId: productId);

      await FirestoreClient()
          .updateFieldInsideDocAsMap(
        path: buisnessCollection,
        docId: businessId,
        fieldName: "workersProductsId",
        value: productId,
      )
          .then((value) async {
        if (value) {
          SettingsData.settings.workersProductsId = productId;
          await FirestoreClient().updateFieldInsideDocAsMap(
            path: usersCollection,
            docId: userId,
            fieldName: "productsIds.$productId",
            value: {"date": Timestamp.now(), "businessId": businessId},
          ).then((value) {
            if (value) {
              UserData.user.productsIds[productId] = {
                "date": Timestamp.fromDate(DateTime.now()),
                "businessId": businessId
              };
            }
          });
        }
      });

      logger.d("User purchase worker sub successfully");
      SubscriptionData.hasPerrmision = true;
      UiManager.insertUpdate(Providers.purchase);
      return true;
    } catch (e) {
      logger.d("Worker Purchase Failed --> $e");
      return false;
    }
  }

  bool selectExistSub(
      {required String revenueCatId,
      required String productId,
      bool isBusinessPurchase = false}) {
    if (isBusinessPurchase) {
      SubscriptionData.availableProductId = productId;
    }
    SubscriptionData.hasPerrmision = true;
    UiManager.insertUpdate(Providers.purchase);
    return true;
  }

  Future<void> presentCodeRedemptionSheet() async {
    await RevenueCatSubscriptionClient().presentCodeRedemptionSheet();
  }

  void updateScreen() => notifyListeners();
}
