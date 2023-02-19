import 'package:management_system_app/app_statics.dart/user_data.dart';
import 'package:management_system_app/services/clients/firestore_client.dart';
import 'package:management_system_app/services/clients/revenueCat/revenucat_client.dart';
import 'package:management_system_app/services/clients/revenue_cat_subscriptions_client.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';

import '../app_const/application_general.dart';
import '../app_const/db.dart';
import '../app_const/platform.dart';
import '../models/purchase_details.dart';
import '../models/purchase_offering.dart';
import '../services/errors_service/app_errors.dart';
import '../services/errors_service/purchase.dart';
import 'language_data.dart';

class SubscriptionData {
  static Map<String, PurchaseOffering> subTypeOfferings = {};
  static Map<String, PurchaseOffering> workersOfferings = {};
  static Map<String, StoreProduct> allProducts = {};
  static bool hasPerrmision = false;
  static bool productsLoaded = false;
  static PurchaseDetails? purchaseDetails;
  static String? availableProductId;
  static List<String> alreadyPurchasedSubs = [];
  static Map<String, bool> isEligibleForTrial = {};

  static Future<void> initPurchasesServer() async {
    if (isWeb) {
      return;
    }
    await RevenueCatClient().init();
    // remove in release
    //await Purchases.setSimulatesAskToBuyInSandbox(true);
  }

  static Future<void> init() async {
    //every time before purchase need to do this
    SubscriptionData.hasPerrmision = false;
    //managers.contains(UserData.user.phoneNumber.replaceAll("+", ""));
    SubscriptionData.availableProductId = null;
    if (SubscriptionData.purchaseDetails == null && !isWeb)
      await setPurchaseDescriptions();
  }

  static Future<void> setPurchaseDescriptions() async {
    try {
      String docName = '';
      switch (LanguageData.currentLaguageCode) {
        case "he":
          docName = hebrewPurchasesDoc;
          break;
        case "en":
          docName = englishPurchasesDoc;
          break;
      }

      await FirestoreClient()
          .getDoc(
              path: generalSettingsCollection,
              docId: docName,
              insideEnviroments: false)
          .then((doc) {
        purchaseDetails = PurchaseDetails.fromJson(doc.data()!);
      });
    } catch (e) {
      logger.d("Error while load the purchase details --> $e");
    }
  }

  static Future<CustomerInfo?> userInfo() async {
    AppErrors.addError(code: purchaseCodeToInt[PurchaseErrorCodes.userInfo]);
    final info = await RevenueCatSubscriptionClient().getUserInfo();
    if (info != null) logger.d("Active subs --> ${info.activeSubscriptions}");
    return info;
  }

  static Future<void> setPurchaseProducts(
      {required String revenueCatId}) async {
    AppErrors.addError(
        code: purchaseCodeToInt[PurchaseErrorCodes.setPurchaseProducts]);
    if (isWeb) return;
    try {
      SubscriptionData.workersOfferings = {};
      SubscriptionData.subTypeOfferings = {};
      final offerings =
          (await RevenueCatSubscriptionClient().getPurchaseOfferings())!
              .all
              .values;
      final currentUserInfo = await userInfo();
      if (currentUserInfo == null) return;
      List<String> activeSubs = currentUserInfo.activeSubscriptions;
      SubscriptionData.alreadyPurchasedSubs = [...activeSubs];

      await Future.forEach(offerings, (offering) async {
        if (offering.identifier.contains("worker")) {
          SubscriptionData.workersOfferings[offering.identifier] =
              PurchaseOffering(products: {});
          offering.availablePackages.forEach((package) async {
            final workerProduct = package.storeProduct;
            SubscriptionData.workersOfferings[offering.identifier]!
                .products[workerProduct.identifier] = workerProduct;
            SubscriptionData.allProducts[workerProduct.identifier] =
                workerProduct;
          });
          SubscriptionData.workersOfferings[offering.identifier]!
              .isAlreadyActive(activeSubs);
        }

        if (offering.identifier.contains("business")) {
          SubscriptionData.subTypeOfferings[offering.identifier] =
              PurchaseOffering(products: {});
          await Future.forEach(offering.availablePackages, (package) async {
            final subTypeProduct = package.storeProduct;
            SubscriptionData.subTypeOfferings[offering.identifier]!
                .products[subTypeProduct.identifier] = subTypeProduct;
            SubscriptionData.allProducts[subTypeProduct.identifier] =
                subTypeProduct;
            SubscriptionData
                    .isEligibleForTrial[package.storeProduct.identifier] =
                (await RevenueCatSubscriptionClient()
                    .checkTrialOrIntroductoryPriceEligibility(
                        productId: package.storeProduct.identifier));
          });
          SubscriptionData.subTypeOfferings[offering.identifier]!
              .isAlreadyActive(activeSubs);
        }
      });

      SubscriptionData.productsLoaded = true;
    } catch (e) {
      logger.e("Error while load products --> $e");
      return;
    }
  }

  static List<String> getAvailableProducts({required String type}) {
    AppErrors.addError(
        code: purchaseCodeToInt[PurchaseErrorCodes.getAvailableProducts]);
    List<String> products = [];
    UserData.user.productsIds.forEach((productId, details) {
      if (productId.contains(type) && details["businessId"] == "") {
        //make a dict of products that no business use them
        products.add(productId);
      }
    });
    return products;
  }

  static Future<List<String>> getActiveSubs(
      {required String revenueCatId}) async {
    final businessInfo = await loginToUser(revenueCatId: revenueCatId);
    return businessInfo == null ? [] : businessInfo.activeSubscriptions;
  }

  static Future<CustomerInfo?> loginToUser(
      {required String revenueCatId}) async {
    //AppErrors.addError(code: purchaseCodeToInt[PurchaseErrorCodes.loginToUser]);

    logger.d("Login to --> $revenueCatId");
    return await RevenueCatSubscriptionClient()
        .loginToUserPurchases(revenueCatId: revenueCatId);
  }

  static void initDetails() {
    SubscriptionData.purchaseDetails = null;
  }
}
