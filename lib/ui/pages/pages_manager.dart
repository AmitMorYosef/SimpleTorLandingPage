import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/providers/settings_provider.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/bottom_bar.dart';
import 'package:simple_tor_web/ui/pages/home_page/home.dart';
import 'package:simple_tor_web/ui/pages/my_bookings_page/my_bookings.dart';

import '../../app_const/operations.dart';
import '../../app_statics.dart/general_data.dart';
import '../../app_statics.dart/screens_data.dart';
import '../../app_statics.dart/user_data.dart';
import '../../services/enable_scroll_options.dart';
import '../general_widgets/buttons/booking_button.dart';

class PagesManager extends StatelessWidget {
  final PageController pagesMangerController = ScreensData.controller;
  late BookingButton bookingButton;
  ScrollController businessPageController = ScrollController();
  ScrollController settingsPageController = ScrollController();

  void executeOperationsIfNeeded() {
    switch (ScreensData.nextOperation) {
      case Operations.openBookingSheet:
        if (bookingButton.openSheet != null) {
          bookingButton.openSheet!(GeneralData.generalContext!);
        }
        break;
      default:
        return;
    }
    ScreensData.cleanOperation();
  }

  @override
  Widget build(BuildContext context) {
    bookingButton = BookingButton(
      ancestorContext: context,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pagesMangerController.jumpToPage(ScreensData.screenIndex);
      executeOperationsIfNeeded();
    });
    context.watch<SettingsProvider>();
    GeneralData.generalContext = context;
    UserData.userListinerAllowUpdate = true;
    businessPageController = ScrollController();
    settingsPageController = ScrollController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      bottomNavigationBar: BottomBar(
        pageController: pagesMangerController,
        onDotClicked: animateToPage,
        screenCount: pagesOrder.length,
      ),
      body: PageView(
        scrollBehavior: EnableScrollOptions(),
        reverse: true,
        controller: pagesMangerController,
        onPageChanged: (value) {
          if (value != ScreensData.screenIndex) ScreensData.screenIndex = value;
        },
        children: pagesOrder,
      ),
    );
  }

  void animateToPage({screenIndex}) {
    pagesMangerController.animateToPage(screenIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  List<Widget> get pagesOrder {
    List<Widget> pages = [
      Home(
          key: UniqueKey(),
          bookingButton: bookingButton,
          businessPageController: businessPageController),
      MyBookings(key: UniqueKey(), bookingButton: bookingButton),
    ];
    ScreensData.screensCount = pages.length;
    return pages;
  }
}
