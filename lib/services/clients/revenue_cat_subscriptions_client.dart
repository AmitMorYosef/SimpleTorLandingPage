import 'package:management_system_app/services/clients/revenueCat/revenucat_client.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app_const/application_general.dart';

class RevenueCatSubscriptionClient {
  static final RevenueCatSubscriptionClient _singleton =
      RevenueCatSubscriptionClient._internal();

  RevenueCatSubscriptionClient._internal();

  factory RevenueCatSubscriptionClient() {
    RevenueCatSubscriptionClient object = _singleton;
    return object;
  }

  final RevenueCatClient revenueCatClient = RevenueCatClient();

  //---------------------------- Purchase -----------------------------

  Future<void> initPurchases() async {
    await revenueCatClient.init();
  }

  Future<CustomerInfo?> getUserInfo() async {
    return await revenueCatClient.getUserInfo();
  }

  Future<Offerings?> getPurchaseOfferings() async {
    return await revenueCatClient.getOfferings();
  }

  Future<List<String>?> getActiveSufbscriptions(
      {required String revenueCatId,
      required String currentRevenueCatId}) async {
    return await revenueCatClient.activeSubscriptions(
        currentRevenueCatId: currentRevenueCatId, revenueCatId: revenueCatId);
  }

  Future<CustomerInfo> purchaseProduct(
      {required String productId, UpgradeInfo? upgradeInfo}) async {
    return await revenueCatClient.purchaseProduct(
        productId: productId, upgardeInfo: upgradeInfo);
  }

  Future<bool> checkTrialOrIntroductoryPriceEligibility(
      {required String productId}) async {
    return await revenueCatClient.checkTrialOrIntroductoryPriceEligibility(
        productId: productId);
  }

  Future<CustomerInfo?> loginToUserPurchases(
      {required String revenueCatId}) async {
    return await revenueCatClient.loginToUserPurchases(
        revenueCatId: revenueCatId);
  }

  Future<void> logoutFromUserPurchases() async {
    try {
      await revenueCatClient.logoutFromUserPurchases();
    } catch (e) {
      logger.e("Error while logout to user purchases");
    }
  }

  Future<void> presentCodeRedemptionSheet() async {
    await revenueCatClient.presentCodeRedemptionSheet();
  }
}
