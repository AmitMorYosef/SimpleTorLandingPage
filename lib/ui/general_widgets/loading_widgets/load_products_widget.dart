// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/platform.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/subscription_data.dart';
import '../../../services/in_app_services.dart/app_launcher.dart';
import '../../../utlis/string_utlis.dart';

class LoadProductsWidget extends StatefulWidget {
  bool isWorker;

  final Widget Function(
    BuildContext context,
  ) childCreator;

  LoadProductsWidget({required this.childCreator, required this.isWorker});

  @override
  State<LoadProductsWidget> createState() => _LoadProductsWidgetState();
}

class _LoadProductsWidgetState extends State<LoadProductsWidget> {
  late Timer _timer;
  double size = 0;

  int _start = 10;

  void startTimer() {
    const onsec = Duration(seconds: 1);
    _timer = Timer.periodic(onsec, (timer) {
      if ((SubscriptionData.productsLoaded &&
              SubscriptionData.purchaseDetails != null) ||
          _start == 0) {
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
    size = widget.isWorker ? gHeight * 0.45 : gHeight * 0.75;
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
    if (isWeb ||
        (SubscriptionData.productsLoaded &&
            SubscriptionData.purchaseDetails != null)) {
      _timer.cancel();
    }

    return SubscriptionData.productsLoaded &&
            SubscriptionData.purchaseDetails != null
        ? widget.childCreator(context)
        : _start == 0 || isWeb
            ? CustomContainer(
                needImage: false,
                showBorder: false,
                alignment: Alignment.center,
                height: size,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: isWeb
                      ? [
                          SizedBox(
                              width: gWidth * 0.5,
                              child: Text(
                                translate("thereIsNoProductsInWeb"),
                                textAlign: TextAlign.center,
                              )),
                          openStoreButton(),
                        ]
                      : [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          )
                        ],
                ))
            : CustomContainer(
                needImage: false,
                showBorder: false,
                color: Theme.of(context).colorScheme.surface,
                alignment: Alignment.center,
                height: size,
                child: Lottie.asset(loadingAnimation, width: 150, height: 150));
  }

  Widget openStoreButton() {
    if (!isWeb) return SizedBox();
    return CustomContainer(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: EdgeInsets.symmetric(
            horizontal: gWidthOriginal * 0.4, vertical: 10),
        needImage: false,
        alignment: Alignment.center,
        onTap: () => AppLauncher().lunchStore(),
        color: Theme.of(context).colorScheme.background,
        child: Text(
          translate("openOnappStore"),
          textAlign: TextAlign.center,
        ));
  }
}
