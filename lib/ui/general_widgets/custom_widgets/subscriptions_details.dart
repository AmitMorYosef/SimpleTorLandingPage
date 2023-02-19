import 'dart:async';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/empty_screen.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/subscription_data.dart';
import '../../../models/purchase_offering.dart';
import '../loading_widgets/load_products_widget.dart';
import '../pickers/subscription_picker.dart/choose_purchase_plan.dart';

class BusinessSubscriptionsDetails extends StatefulWidget {
  BusinessSubscriptionsDetails({super.key});

  @override
  State<BusinessSubscriptionsDetails> createState() =>
      _BusinessSubscriptionsDetailsState();
}

class _BusinessSubscriptionsDetailsState
    extends State<BusinessSubscriptionsDetails> {
  late Timer _timer;
  late String currentProduct;

  int _start = 10;

  void startTimer() {
    const onsec = Duration(seconds: 1);
    _timer = Timer.periodic(onsec, (timer) {
      if (finishLoading() || _start == 0) {
        setState(() {
          _timer.cancel();
        });
      } else {
        _start--;
      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (finishLoading()) {
      _timer.cancel();
    }
    return finishLoading()
        ? tabs()
        : _start == 0
            ? CustomContainer(
                needImage: false,
                alignment: Alignment.center,
                height: gHeight * 0.3 + 50,
                borderWidth: 0,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ))
            : CustomContainer(
                needImage: false,
                borderWidth: 0,
                alignment: Alignment.center,
                height: gHeight * 0.3 + 50,
                child: Lottie.asset(loadingAnimation, width: 150, height: 150));
  }

  Widget tabs() {
    return DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {}
          });
          return Column(
            children: [
              TabBar(
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  tab(translate("activeSubs")),
                  tab(translate("pendingSubs")),
                ],
                indicatorColor: Theme.of(context).colorScheme.secondary,
              ),
              Center(
                child: SizedBox(
                  width: gWidth,
                  height: gHeight * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          activeSubs(),
                          pendingSubs(),
                        ]),
                  ),
                ),
              ),
            ],
          );
        }));
  }

  bool finishLoading() {
    return SubscriptionData.purchaseDetails != null ||
        (SettingsData.settings.productId == "" &&
            SettingsData.settings.workersProductsId == "" &&
            SettingsData.settings.pendingProductId == "" &&
            SettingsData.settings.pendingWorkersProductsId == "");
  }

  Widget tab(String text) {
    return Container(
      alignment: Alignment.center,
      height: 50,
      child: Text(text),
    );
  }

  Widget pendingSubs() {
    if (SettingsData.settings.pendingProductId == "" &&
        SettingsData.settings.pendingWorkersProductsId == "") {
      return EmptyScreen(
        height: gHeight * 0.3 - 30,
        width: gWidth * 0.45,
        fontSize: 20,
        text: translate("noPendingSubsBelongToBusiness"),
      );
    }
    return Column(
      children: [
        subItem(SettingsData.settings.pendingProductId, () {}, false),
        subItem(SettingsData.settings.pendingWorkersProductsId, () {}, false),
      ],
    );
  }

  Widget activeSubs() {
    if (SettingsData.settings.productId == "" &&
        SettingsData.settings.workersProductsId == "") {
      return EmptyScreen(
        height: gHeight * 0.3 - 30,
        width: gWidth * 0.45,
        fontSize: 20,
        text: translate("noSubsBelongToBusiness"),
      );
    }
    return Column(
      children: [
        subItem(SettingsData.settings.productId, changeSub,
            SettingsData.settings.pendingProductId == ""),
        subItem(SettingsData.settings.workersProductsId, changeSub,
            SettingsData.settings.pendingWorkersProductsId == "")
      ],
    );
  }

  void changeSub() {
    bool isWorker = this.currentProduct.contains("worker");
    SubscriptionData.init();
    SlidingBottomSheet(
            context: context,
            sheet: LoadProductsWidget(
                childCreator: purchasePlanSheet, isWorker: isWorker),
            size: 1)
        .showSheet();
  }

  Widget purchasePlanSheet(BuildContext context) {
    bool isWorker = this.currentProduct.contains("worker");
    Map<String, PurchaseOffering> offeringForUse = {};

    isWorker
        ? SubscriptionData.workersOfferings.forEach((offeringId, offering) {
            if (offering.products
                .containsKey(SettingsData.settings.workersProductsId)) {
              offeringForUse = {offeringId: offering};
            }
          })
        : SubscriptionData.subTypeOfferings.forEach((offeringId, offering) {
            if (offering.products.containsKey(this.currentProduct)) {
              offeringForUse = {offeringId: offering};
            }
          });

    return Container(
        color: Theme.of(context).colorScheme.surface,
        child: ChoosePurchasePlan(
          availableProducts: [],
          productsToNotShow: SubscriptionData.alreadyPurchasedSubs,
          changePlan: true,
          workerSubscription: isWorker,
          offerings: offeringForUse,
        ));
  }

  Widget subItem(String product, Function onPressChange, bool showChange) {
    final details = SubscriptionData.purchaseDetails!.productsNames;
    return details.containsKey(product)
        ? CustomContainer(
            image: null,
            width: gWidth * 0.95,
            borderWidth: 2,
            margin: EdgeInsets.symmetric(vertical: 5),
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: gWidth * 0.8,
                      child: Text(
                        details[product]!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                      )),
                  showChange
                      ? BouncingWidget(
                          child: Icon(Icons.change_circle,
                              color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: () {
                            this.currentProduct = product;
                            onPressChange();
                          })
                      : SizedBox()
                ],
              ),
            ))
        : SizedBox();
  }
}
