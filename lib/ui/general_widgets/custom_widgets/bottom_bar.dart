import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../app_const/app_sizes.dart';
import '../../../services/in_app_services.dart/language.dart';

// ignore: must_be_immutable
class BottomBar extends StatelessWidget {
  PageController pageController;
  int screenCount;
  Function({required int screenIndex})? onDotClicked;
  BottomBar(
      {required this.pageController,
      required this.screenCount,
      this.onDotClicked});

  @override
  Widget build(BuildContext context) {
    final singleDotSize = 10.0;
    final spaceBetweenDot = 8.0;
    double indicatorWidth =
        (singleDotSize + spaceBetweenDot) * (screenCount) - 8;
    return Padding(
      padding: EdgeInsets.only(
          left: max(0, (gWidthOriginal - indicatorWidth) * .5),
          bottom: 40,
          right: max(0, (gWidthOriginal - indicatorWidth) * .5)),
      child: SmoothPageIndicator(
          textDirection: ApplicationLocalizations.of(context)!.isRTL()
              ? TextDirection.ltr
              : TextDirection.rtl,
          controller: pageController, // PageController
          count: screenCount,
          effect: WormEffect(
              spacing: spaceBetweenDot,
              dotWidth: singleDotSize,
              dotHeight: singleDotSize,
              dotColor: Colors.grey,
              activeDotColor: Theme.of(context).colorScheme.secondary),
          onDotClicked: (index) {
            if (onDotClicked != null) onDotClicked!(screenIndex: index);
          }),
    );
  }
}
