import 'package:flutter/material.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/bottom_bar.dart';
import 'package:management_system_app/ui/pages/home_page/home.dart';
import 'package:management_system_app/ui/pages/my_bookings_page/my_bookings.dart';
import 'package:management_system_app/ui/pages/settings_page/settings.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/schedule_page.dart';
import 'package:provider/provider.dart';

import '../../app_const/app_sizes.dart';
import '../../app_const/operations.dart';
import '../../app_statics.dart/general_data.dart';
import '../../app_statics.dart/screens_data.dart';
import '../../app_statics.dart/user_data.dart';
import '../../services/enable_scroll_options.dart';
import '../general_widgets/buttons/booking_button.dart';
import '../pages_opener.dart';

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
      case Operations.creatBusiness:
        PagesOpener()
            .openBusinessCreation(context: GeneralData.generalContext!);
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
    return Stack(
      children: [
        Scaffold(
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
              if (value != ScreensData.screenIndex)
                ScreensData.screenIndex = value;
            },
            children: pagesOrder,
          ),
        ),
        Visibility(
          visible: false,
          child: Material(
            color: Colors.black.withOpacity(0.5),
            child: Container(
                height: gHeight,
                width: gWidthOriginal,
                child: Stack(
                  children: [
                    Positioned(
                      top: gHeight * 0.2,
                      child: TextButton(
                          onPressed: () {
                            pagesMangerController.animateToPage(0,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.linear);
                          },
                          child: Text("dd")),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  void animateToPage({screenIndex}) {
    pagesMangerController.animateToPage(screenIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  List<Widget> get pagesOrder {
    List<Widget> pages = UserData.getPermission() == 0
        ? [
            SettingsPage(
                key: UniqueKey(),
                settingsPageController: settingsPageController),
            Home(
                key: UniqueKey(),
                bookingButton: bookingButton,
                businessPageController: businessPageController),
            MyBookings(key: UniqueKey(), bookingButton: bookingButton),
          ]
        : [
            SettingsPage(
                key: UniqueKey(),
                settingsPageController: settingsPageController),
            Home(
                key: UniqueKey(),
                bookingButton: bookingButton,
                businessPageController: businessPageController),
            SchedulePage(key: UniqueKey()),
            MyBookings(key: UniqueKey(), bookingButton: bookingButton),
          ];
    ScreensData.screensCount = pages.length;
    return pages;
  }
}
