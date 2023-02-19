import 'dart:io';

import 'package:management_system_app/secrets.dart';
import 'package:management_system_app/services/clients/revenueCat/make_request_revenuecat.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../app_const/application_general.dart';
import '../../../app_const/platform.dart';

class RevenueCatClient {
  MakeRequestRevenueCat _makeRequestRevenueCat = MakeRequestRevenueCat();
  PurchasesConfiguration? purchaseConfig;
  Future<void> init() async {
    if (isWeb)
      return;
    else if (Platform.isIOS)
      purchaseConfig = PurchasesConfiguration(purchaseAppleConfigKey);
    else {
      purchaseConfig = PurchasesConfiguration(purchaseGoogleConfigKey)
        ..observerMode = false;
    }

    await Purchases.configure(purchaseConfig!);
  }

  Future<CustomerInfo?> loginToUserPurchases(
      {required String revenueCatId}) async {
    try {
      final result = await Purchases.logIn(revenueCatId);
      final info = result.customerInfo;
      return info;
    } catch (e) {
      logger.i("Error while login to user purchases --> $e");
      return null;
    }
  }

  Future<List<String>> activeSubscriptions(
      {required String revenueCatId,
      required String currentRevenueCatId}) async {
    if (isWeb) {
      try {
        final userJson = await _makeRequestRevenueCat.performRequst(
          endpoint: "/subscribers/${revenueCatId}",
        );
        List<String> activeSubs = [];
        userJson!["subscriber"]["subscriptions"]
            .forEach((subscription, details) {
          if (details["unsubscribe_detected_at"] == null) {
            activeSubs.add(subscription);
          }
        });
        return activeSubs;
      } catch (e) {
        logger.e("Error while get the user active subs from api --> $e");
        return [];
      }
    } else {
      final result = await Purchases.logIn(revenueCatId);
      final info = result.customerInfo;

      if (currentRevenueCatId != "") {
        await Purchases.logIn(currentRevenueCatId);
      } else {
        await Purchases.logOut();
      }
      return info.activeSubscriptions;
    }
  }

  Future<bool> checkTrialOrIntroductoryPriceEligibility(
      {required String productId}) async {
    if (isWeb) return false;
    if (Platform.isAndroid) return false;
    final result =
        await Purchases.checkTrialOrIntroductoryPriceEligibility([productId]);

    return result.values.first.status ==
        IntroEligibilityStatus.introEligibilityStatusEligible;
  }

  Future<void> logoutFromUserPurchases() async {
    if (isWeb) return;

    await Purchases.logOut();
  }

  Future<Offerings?> getOfferings() async {
    if (isWeb) return null;
    return await Purchases.getOfferings();
  }

  Future<CustomerInfo?> getUserInfo() async {
    if (isWeb) return null;
    return await Purchases.getCustomerInfo();
  }

  Future<void> presentCodeRedemptionSheet() async {
    await Purchases.presentCodeRedemptionSheet();
  }

  Future<CustomerInfo> purchaseProduct(
      {required String productId, UpgradeInfo? upgardeInfo}) async {
    return await Purchases.purchaseProduct(productId, upgradeInfo: upgardeInfo);
  }
}
