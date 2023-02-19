import 'package:flutter/material.dart';
import 'package:iso_duration_parser/iso_duration_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/subscription_data.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/string_utlis.dart';
import '../../custom_widgets/animated_loading_text.dart';
import '../../custom_widgets/bullet_list_text.dart';
import '../../custom_widgets/custom_container.dart';

// ignore: must_be_immutable
class ProductItem extends StatelessWidget {
  String offeringId;
  StoreProduct product;
  double productWidth;
  int index;
  double productHeight;
  String revenueCatId;
  bool isMostPopular, isError, purchased, isLoading, newPurchase;

  ProductItem(
      {required this.offeringId,
      required this.product,
      required this.productHeight,
      required this.productWidth,
      required this.index,
      required this.revenueCatId,
      required this.isMostPopular,
      required this.isError,
      required this.purchased,
      required this.isLoading,
      required this.newPurchase});

  @override
  Widget build(BuildContext context) {
    String introductoryText = "";
    if (product.introductoryPrice != null &&
        SubscriptionData.isEligibleForTrial.containsKey(product.identifier) &&
        SubscriptionData.isEligibleForTrial[product.identifier]!) {
      Duration duration = isoDurationToDuration(
          IsoDuration.parse(product.introductoryPrice!.period));
      introductoryText =
          translate("trialPeriod") + ": " + durationToString(duration);
    }

    List<String> description = SubscriptionData
        .purchaseDetails!.productsDescription[product.identifier]!;
    if (introductoryText != "") description = [introductoryText] + description;
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        CustomContainer(
          width: productWidth,
          height: productHeight,
          opacity: isLoading || isError ? 0.4 : 1,
          margin: EdgeInsets.only(top: 20),
          boxBorder: purchased
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary, width: 2)
              : isMostPopular
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface, width: 2)
                  : null,
          padding: EdgeInsets.only(top: isMostPopular || purchased ? 30 : 10),
          child: SizedBox(
            height: productHeight,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [title(context), benefitsList(description), price()]),
          ),
        ),
        isMostPopular && !purchased
            ? isMostPopularIndicator(context)
            : SizedBox(),
        purchased ? isPurchasedIndicator(context) : SizedBox(),
        isLoading ? isLoadingIndicator() : SizedBox(),
        isError ? isErrorIndicator() : SizedBox()
      ],
    );
  }

  Widget title(BuildContext context) {
    return SizedBox(
      width: gWidth * 0.5,
      child: Text(
        SubscriptionData.purchaseDetails!.productsNames[product.identifier]!,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget price() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Text(
            product.priceString +
                "/" +
                translate("month") +
                "\n" +
                translate("includesVAT"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          purchased
              ? Text(
                  translate("canUseForSub"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                )
              : Text(
                  translate("pressToPurchase"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
        ],
      ),
    );
  }

  Widget benefitsList(List<String?> description) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        width: productWidth,
        child: SingleChildScrollView(
          child: BulletListText(
            lines: description,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget isMostPopularIndicator(BuildContext context) {
    return CustomContainer(
      alignment: Alignment.center,
      raduis: 15,
      boxBorder:
          Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
      height: gHeight * .05,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(translate("theMostPopular")),
    );
  }

  Widget isPurchasedIndicator(BuildContext context) {
    return CustomContainer(
      alignment: Alignment.center,
      raduis: 15,
      boxBorder:
          Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
      height: gHeight * .05,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(translate("purchased")),
    );
  }

  Widget isErrorIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: gWidth * 0.5,
            child: Text(translate("purchaseError"),
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }

  Widget isLoadingIndicator() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(loadingAnimation, width: 100, height: 100),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          width: gWidth * 0.5,
          child: AnimatedLoadingText(
            stopEnd: true,
            textStyle: TextStyle(fontSize: 18),
            duration: Duration(seconds: 10),
            textToLoad: [
              translate("createSecureConnection"),
              translate("encryptingData"),
              translate("encryptionSeccussed"),
              translate("secureLineCreated"),
            ],
          ),
        ),
      ],
    ));
  }
}
