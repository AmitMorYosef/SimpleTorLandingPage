// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/models/purchase_offering.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_button.dart';
import 'package:management_system_app/ui/general_widgets/pickers/subscription_picker.dart/arrows.dart';
import 'package:management_system_app/ui/general_widgets/pickers/subscription_picker.dart/product_item.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/subscription_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../providers/manager_provider.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/string_utlis.dart';
import '../../dialogs/genral_dialog.dart';
import '../../policy_and_terms.dart';

class ChoosePurchasePlan extends StatelessWidget {
  bool workerSubscription;
  bool changePlan;
  ScrollController scrollController = ScrollController();
  double productHeight = 0;
  final productWidth = gWidth * .68;
  late SubscriptionProvider subscriptionProvider;
  List<String> availableProducts;
  List<String> productsToNotShow;
  Map<String, PurchaseOffering> offerings;

  bool isNewBusiness;
  ChoosePurchasePlan(
      {super.key,
      required this.offerings,
      this.isNewBusiness = false,
      this.changePlan = false,
      this.productsToNotShow = const [],
      this.workerSubscription = false,
      this.availableProducts = const []});

  List<LoadingButton> suggestionItems = [];

  @override
  Widget build(BuildContext context) {
    productHeight = workerSubscription ? gHeight * 0.25 : gHeight * 0.55;
    subscriptionProvider = context.watch<SubscriptionProvider>();

    int index = 0;
    suggestionItems = [];

    // create loading buttons for the purchased items
    availableProducts.forEach((productId) {
      suggestionItems.add(LoadingButton(
        key: UniqueKey(),
        neewUiUpdate: true,
        errorState: productItem(
            context: context,
            offeringId: "",
            product: SubscriptionData.allProducts[productId]!,
            index: index,
            isError: true,
            purchased: true,
            newPurchase: false),
        startState: productItem(
            context: context,
            offeringId: "",
            product: SubscriptionData.allProducts[productId]!,
            index: index,
            purchased: true,
            newPurchase: false),
        middleState: productItem(
            context: context,
            offeringId: "",
            product: SubscriptionData.allProducts[productId]!,
            index: index,
            isLoading: true,
            purchased: true,
            newPurchase: false),
      ));
      index += 1;
    });

    Set<String> alreadyIn = {};

    // create loading buttons for the pruchase plans
    offerings.forEach((offeringId, offering) {
      if (!offering.inUsed || changePlan) {
        offering.products.forEach((productId, product) {
          if (!alreadyIn
                  .contains(product.title.replaceAll(' (Simple Tor)', '')) &&
              !productsToNotShow.contains(productId)) {
            suggestionItems.add(LoadingButton(
              key: UniqueKey(),
              neewUiUpdate: true,
              errorState: productItem(
                  context: context,
                  offeringId: offeringId,
                  product: product,
                  index: index,
                  isError: true),
              startState: productItem(
                context: context,
                offeringId: offeringId,
                product: product,
                index: index,
              ),
              middleState: productItem(
                  context: context,
                  offeringId: offeringId,
                  product: product,
                  index: index,
                  isLoading: true),
            ));
            index += 1;
            alreadyIn.add(product.title.replaceAll(' (Simple Tor)', ''));
          }
        });
      }
    });

    return SingleChildScrollView(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                    changePlan
                        ? translate("changePlan")
                        : workerSubscription
                            ? translate("purchaseWorker")
                            : UserData.user.previews
                                    .containsKey(SettingsData.appCollection)
                                ? translate("publishABusiness")
                                : translate("renewBusiness"),
                    style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(
                  height: 10,
                ),
                !SubscriptionData.hasPerrmision
                    ? Text(translate("choosePurchasePlan"),
                        style: Theme.of(context).textTheme.titleLarge)
                    : SizedBox(
                        height: 40,
                      ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    alignment: Alignment.center,
                    height: productHeight + 20,
                    child: SubscriptionData.hasPerrmision
                        ? successWidget(context)
                        : plansList()),
                SubscriptionData.hasPerrmision || suggestionItems.isEmpty
                    ? SizedBox(
                        height: 20,
                      )
                    : policyAndTerms(context),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          SubscriptionData.hasPerrmision ||
                  suggestionItems.isEmpty ||
                  suggestionItems.length == 1
              ? SizedBox()
              : Arrows(
                  itemWidth: productWidth,
                  scrollController: scrollController,
                )
        ],
      ),
    );
  }

  Widget productItem(
      {required String offeringId,
      required StoreProduct product,
      required int index,
      required BuildContext context,
      bool isError = false,
      bool purchased = false,
      bool isLoading = false,
      bool newPurchase = true}) {
    final isMostPopular = product.identifier.contains("advanced");
    return GestureDetector(
        onTap: () async {
          bool? resp = true;
          if (changePlan) {
            resp = await explainDialog(context, translate("changePlansAuto"));
          }
          if (resp == true) {
            purchase(context, product, index, offeringId,
                revenueCatId: UserData.user.revenueCatId,
                newPurchase: newPurchase);
          }
        },
        child: ProductItem(
          offeringId: offeringId,
          product: product,
          productWidth: productWidth,
          productHeight: productHeight,
          index: index,
          newPurchase: newPurchase,
          isError: isError,
          isLoading: isLoading,
          isMostPopular: isMostPopular,
          purchased: purchased,
          revenueCatId: UserData.user.revenueCatId,
        ));
  }

  Future<bool?> explainDialog(BuildContext context, String text) async {
    return await genralDialog(
        context: context,
        title: translate('explanation'),
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(translate('no'))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(translate('yes'))),
        ]);
  }

  Widget successWidget(BuildContext context) {
    return Container(
      width: gWidth * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              changePlan
                  ? translate("planChangedSuccessfully")
                  : workerSubscription
                      ? translate("workerPurchasedSuccessfully")
                      : translate("everythingSetYouCanContinue"),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontSize: 20)),
          SizedBox(
            height: 10,
          ),
          Lottie.asset(successAnimation,
              width: gHeight * 0.1, height: gHeight * 0.1, repeat: false),
        ],
      ),
    );
  }

  Widget plansList() {
    return suggestionItems.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Text(translate("noAvailableProducts"),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 19)),
            ],
          )
        : ScrollSnapList(
            listController: scrollController,
            onItemFocus: (index) {},
            scrollDirection: Axis.horizontal,
            itemCount: suggestionItems.length,
            duration: 100,
            dynamicItemSize: true,
            curve: Curves.bounceIn,
            itemSize: productWidth, // card height + padding
            itemBuilder: ((context, index) {
              return suggestionItems[index];
            }),
          );
  }

  void purchase(
      BuildContext context, StoreProduct product, int index, String offeringId,
      {required String revenueCatId, required bool newPurchase}) async {
    bool alreadyLoading = false;
    suggestionItems.forEach((item) {
      if (item.isNowLoading) {
        alreadyLoading = true;
        return;
      }
    });
    if (alreadyLoading) return;

    await suggestionItems[index].load!(
        startState: productItem(
            context: context,
            offeringId: offeringId,
            product: product,
            index: index,
            newPurchase: newPurchase),
        endState: productItem(
            context: context,
            offeringId: offeringId,
            product: product,
            index: index,
            newPurchase: newPurchase),
        future: () {
          if (workerSubscription) {
            return changePlan
                ? changePurchasePlan(product.identifier)
                : newPurchase
                    ? purchaseWorker(offeringId, product.identifier)
                    : selectExistWorker(
                        productId: product.identifier,
                        revenueCatId: revenueCatId);
          } else {
            return changePlan
                ? changePurchasePlan(product.identifier,
                    isBusinessPurchase: true)
                : newPurchase
                    ? renewSub(context, offeringId, product.identifier)
                    : renewBusinessWithExistSub(
                        context, product.identifier, revenueCatId);
          }
        });
  }

  Future<bool> cantBuy() async {
    return false;
  }

  Future<bool> changePurchasePlan(String productId,
      {bool isBusinessPurchase = false}) async {
    /* only buy the product and change the pending product
    the listeners will update the business product in the data base 
    when the product will change in the apps stores */
    return await subscriptionProvider
        .changePurchasePlan(
            productId: productId,
            oldProductId: isBusinessPurchase
                ? SettingsData.settings.productId
                : SettingsData.settings.workersProductsId,
            revenueCatId: UserData.user.revenueCatId)
        .then((value) async {
      if (value) {
        return await ManagerProvider.changeSub(
            buisnessId: SettingsData.appCollection,
            productId: productId,
            isBusinessPurchase: isBusinessPurchase);
      }
      return value;
    });
  }

  Future<bool> renewBusinessWithExistSub(
      BuildContext context, String productId, String revenueCatId) async {
    bool resp = subscriptionProvider.selectExistSub(
        productId: productId, revenueCatId: revenueCatId);
    if (resp) {
      return await ManagerProvider.purchaseSubAfterExpiration(
              businessId: SettingsData.appCollection,
              productId: productId,
              revenueCatId: revenueCatId)
          .then(
        (value) async {
          SettingsData.updateBusinessLimits(
              subTypeFromProductId(productId, SettingsData.appCollection));
          SettingsData.setActiveBusiness(productId: productId);
          return value;
        },
      );
    } else {
      return false;
    }
  }

  Future<bool> renewSub(
      BuildContext context, String offeringId, String productId) async {
    return await subscriptionProvider
        .purchaseBusiness(
      revenueCatId: UserData.user.revenueCatId,
      productId: productId,
    )
        .then((value) async {
      if (value)
        await ManagerProvider.purchaseSubAfterExpiration(
                businessId: SettingsData.appCollection,
                productId: productId,
                revenueCatId: UserData.user.revenueCatId)
            .then((value) async {
          if (value) {
            // remove the product from the map - cant be used twice
            SubscriptionData.subTypeOfferings[offeringId]!.inUsed = true;
            SubscriptionData.alreadyPurchasedSubs.add(productId);
            SettingsData.updateBusinessLimits(
                subTypeFromProductId(productId, SettingsData.appCollection));
            SettingsData.setActiveBusiness(productId: productId);
          }
        });
      else
        CustomToast(context: context, msg: translate("transactionFaild"))
            .init();
      return value;
    });
  }

  Future<bool> purchaseWorker(String offeringId, String productId) async {
    return await subscriptionProvider
        .purchaseWorker(
            businessId: SettingsData.appCollection,
            productId: productId,
            userId: UserData.user.phoneNumber)
        .then(
      (value) {
        if (value) {
          // remove the product from the map - cant be used twice
          SubscriptionData.workersOfferings[offeringId]!.inUsed = true;
          SubscriptionData.alreadyPurchasedSubs.add(productId);
          SettingsData.setEligibleWorkerAmount(productId);
        }
        return value;
      },
    );
  }

  Future<bool> selectExistWorker(
      {required String productId, required revenueCatId}) async {
    bool resp = subscriptionProvider.selectExistSub(
        isBusinessPurchase: false,
        revenueCatId: revenueCatId,
        productId: productId);

    if (resp) {
      return await ManagerProvider.purchaseSubAfterExpiration(
              businessId: SettingsData.appCollection,
              productId: productId,
              isBusinessPurchase: false,
              revenueCatId: revenueCatId)
          .then(
        (value) {
          if (value) {
            SettingsData.setEligibleWorkerAmount(productId);
          }
          return value;
        },
      );
    } else {
      return false;
    }
  }
}
