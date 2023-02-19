import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/animations/enter_animation.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/booking_model.dart';
import '../../../../models/worker_model.dart';
import '../buisness.dart';

// ignore: must_be_immutable
class Reminder extends StatelessWidget {
  late String name, time, bookingText, workerName, date, updateText;
  late List<Booking> userBookings;
  late WorkerModel? currentWorker;

  SheetController? controller;
  Reminder({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    name = UserData.user.name;
    userBookings = UserData.user.bookings.values.toList();

    if (Buisness.firstBooking == null && Buisness.firstUpdate == null) {
      return SizedBox();
    }

    if (Buisness.firstBooking != null) {
      date =
          DateFormat('dd-MM-yyyy').format(Buisness.firstBooking!.bookingDate);

      time = DateFormat('HH:mm').format(Buisness.firstBooking!.bookingDate);

      currentWorker = SettingsData.workers[Buisness.firstBooking!.workerId];
      if (currentWorker == null) bookingText = translate('unavailableBooking');

      if (currentWorker != null) {
        workerName = currentWorker!.name;
        bookingText =
            "${translate('youHaveBookingTo')} $workerName ${translate('today')}\n ${translate('inDate')}: $date ${translate('at')} $time.";
      }
    }

    return Center(
      child: Container(
        width: gWidthOriginal,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: EnterAnimation(paddingFromTop: 10, childCreator: content),
      ),
    );
  }

  Widget content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Buisness.firstBooking != null ? booking(context) : SizedBox(),
          Buisness.firstUpdate != null && Buisness.firstBooking != null
              ? SizedBox(
                  height: 10,
                )
              : SizedBox(),
          Buisness.firstUpdate != null ? update(context) : SizedBox(),
          Lottie.asset(attentionAnimation, width: 50, height: 50, repeat: false)
        ],
      ),
    );
  }

  Widget update(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            translate('newUpdate') + '!!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            Buisness.firstUpdate!.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 17, color: Theme.of(context).colorScheme.secondary),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            width: gWidth * 0.4,
            child: Text(
              Buisness.firstUpdate!.content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget booking(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              translate('remainder') + '!!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Text(
            bookingText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
