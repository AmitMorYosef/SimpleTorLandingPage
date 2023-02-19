import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import 'package:management_system_app/ui/helpers/fonts_helper.dart';
import 'package:management_system_app/ui/pages_opener.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/purchases.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../providers/booking_provider.dart';
import '../../../utlis/general_utlis.dart';
import '../../pages/booking_page/booking.dart';

// ignore: must_be_immutable
class BookingButton extends StatefulWidget {
  bool isMyBookings;
  BuildContext ancestorContext;
  void Function(BuildContext)? openSheet;
  BookingButton(
      {super.key, required this.ancestorContext, this.isMyBookings = false});

  @override
  State<BookingButton> createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  late BookingProvider bookingProvider;

  int bookingLimit = 0;

  int bookingsCount = 0;

  @override
  void initState() {
    super.initState();
    widget.openSheet = clickButton;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bookingProvider = context.read<BookingProvider>();

    if (SettingsData.appCollection == '') return SizedBox();
    if (!SettingsData.activeBusiness) return SizedBox();
    if (SettingsData.isPassedLimit()) return SizedBox();

    bookingLimit =
        SettingsData.settings.limits[BuisnessLimitations.bookingCount]!;

    bookingsCount = 0;
    UserData.user.bookings.forEach((bookingId, booking) {
      if (booking.buisnessId == SettingsData.appCollection) bookingsCount += 1;
    });

    return GestureDetector(
        onTap: () => clickButton(context),
        child: Container(
          child: Column(
            children: [
              Lottie.asset(
                clockAnimation,
                height: gHeight * 0.1,
                width: gHeight * 0.1,
                repeat: false,
              ),
              Center(
                child: Text(
                  translate('setBooking'),
                  style: FontsHelper().businessStyle(),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ));
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   context.dependOnInheritedWidgetOfExactType();
  // }

  void clickButton(BuildContext context) async {
    if (!UserData.isConnected()) {
      await PagesOpener().openLogin(context: context, openBookingSheet: true);
      return;
    }
    if (!await isNetworkConnected()) {
      notNetworkConnectedToast(context);
      return;
    }
    if (SettingsData.settings.blockedUsers
        .containsKey(UserData.user.phoneNumber)) {
      CustomToast(context: context, msg: translate("blockUser")).init();
      return;
    }
    if (bookingLimit > bookingsCount) {
      BookingProvider.setup();
      BookingProvider.booking.customerPhone = UserData.user.phoneNumber;
      BookingProvider.setSheetOpen(false);
      UserData.userListinerAllowUpdate = false;
      //UserData.cancelListening();
      await SlidingBottomSheet(
              context: widget.ancestorContext,
              sheet: BookingSheet(
                ancestorContext: widget.ancestorContext,
              ),
              size: 1)
          .showSheet();
      SettingsData.cancelWorkerListening();
      UserData.userListinerAllowUpdate = true;
      // if (widget.isMyBookings) {
      //   UserData.userListinerAllowUpdate = true;
      //   //UserData.startLisening();
      // }
    } else {
      CustomToast(
        context: context,
        msg: "${translate('crossBokingsLimit')} - ${bookingLimit}", // message
        gravity: ToastGravity.CENTER, // location
      ).init();
    }
  }
}
