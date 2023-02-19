import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:simple_tor_web/ui/general_widgets/buttons/booking_button.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/drop_down_menu.dart';
import 'package:simple_tor_web/ui/pages/my_bookings_page/widgets/booking_card.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/application_general.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../models/booking_model.dart';
import '../../../providers/device_provider.dart';
import '../../../services/enable_scroll_options.dart';

// ignore: must_be_immutable
class MyBookings extends StatefulWidget {
  final BookingButton bookingButton;
  MyBookings({super.key, required this.bookingButton});
  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings>
    with SingleTickerProviderStateMixin {
  bool displaySwitch = true;

  late String avaliableBookings;

  late int bookingLength;

  late List<Booking> bookings;
  late BuildContext _context;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    displaySwitch = !context.read<DeviceProvider>().isAllowedNotification;
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    animation = Tween<double>(begin: 1, end: .0).animate(controller);
    UserData.userListinerAllowUpdate = true;
    //UserData.startLisening();
  }

  @override
  void dispose() {
    UserData.userListinerAllowUpdate = false;
    controller.dispose();
    //UserData.cancelListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    bookings = UserData.showCurrentBookings
        ? UserData.user.bookings.values.toList()
        : UserData.user.passedBookings.values.toList();

    bookings.sort((a, b) => a.bookingDate.millisecondsSinceEpoch
        .compareTo(b.bookingDate.millisecondsSinceEpoch));
    bookingLength = bookings.length;

    if (UserData.showCurrentBookings) {
      bookingLength == 0
          ? avaliableBookings = ''
          : bookingLength == 1
              ? avaliableBookings = translate('youHaveOneAvailableBookings')
              : bookingLength == 2
                  ? avaliableBookings = translate('youHaveAvailableBookings')
                  : bookingLength > 2
                      ? avaliableBookings =
                          "${translate('youHave')} ${bookingLength.toString()} ${translate('availableBookings')}"
                      : null;
    } else {
      bookingLength == 0
          ? avaliableBookings = ''
          : bookingLength == 1
              ? avaliableBookings = translate('youHadOneBooking')
              : bookingLength == 2
                  ? avaliableBookings = translate('youHadTwoBookings')
                  : bookingLength > 2
                      ? avaliableBookings =
                          "${translate("youHad")} ${bookingLength.toString()} ${translate('bookings')}"
                      : null;
    }

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              Center(
                child:
                    Padding(padding: const EdgeInsets.all(8.0), child: title()),
              ),
              bookingLength != 0
                  ? bookingLength == 1
                      ? singleItem()
                      : Expanded(
                          child: Container(
                              padding: EdgeInsets.only(bottom: gHeight * .1),
                              width: gWidth * .8,
                              child: dynamicList()),
                        )
                  : Padding(
                      padding: EdgeInsets.only(top: gHeight * 0.3),
                      child: Text(translate('noAvailableBookings'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 22)),
                    ),
            ],
          ),
          Positioned(
              right: 0, bottom: gHeight * 0.1, child: widget.bookingButton)
        ],
      ),
    );
  }

  Widget title() {
    return Column(
      children: [
        UserData.isConnected() ? bookingStateMenu() : SizedBox(),
        SizedBox(
          height: 3,
        ),
        Text(avaliableBookings,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        SizedBox(
          height: 10,
        ),
        UserData.isConnected() ? getUpdatesOnChanges() : SizedBox()
      ],
    );
  }

  Widget singleItem() {
    return Padding(
      padding: EdgeInsets.only(top: gHeight * 0.2),
      child: BookingCard(ancestorContext: context, booking: bookings[0]),
    );
  }

  Widget dynamicList() {
    return ScrollConfiguration(
      behavior: EnableScrollOptions(),
      child: ScrollSnapList(
        onItemFocus: (index) {},
        scrollDirection: Axis.vertical,
        itemCount: bookingLength,
        duration: 100,
        dynamicItemSize: true,
        itemSize: 290, // card height + padding
        itemBuilder: ((context, index) =>
            BookingCard(ancestorContext: context, booking: bookings[index])),
      ),
    );
  }

  Widget getUpdatesOnChanges() {
    return Visibility(
      visible: displaySwitch,
      child: FadeTransition(
        opacity: animation,
        child: SizedBox(
          width: gWidth * .8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: gWidth * .6,
                  child: Text(
                    translate("notifyBookingChangedInfo"),
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 16),
                  )),
              // NotificationSwitch(
              //   afterAllowed: (() => Future.delayed(Duration(milliseconds: 0))
              //       .then((value) => setState(() {
              //             controller.forward();
              //           }))),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget bookingStateMenu() {
    Map<String, String> optionMap = {
      "present": translate("futureBookings"),
      "past": translate("pastBookings")
    };

    return DropDownMenu(
      key: UniqueKey(),
      initialValue: UserData.showCurrentBookings ? "present" : "past",
      values: optionMap,
      ratio: 1.5,
      onChanged: onChanged,
    );
  }

  void onChanged(String value) {
    UserData.showCurrentBookings = value == "present";
    UiManager.insertUpdate(Providers.user);
    UiManager.updateUi(context: _context);
  }
}
