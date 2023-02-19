import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/booking_provider.dart';
import '../../../app_const/worker_scedule.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../models/booking_model.dart';

// ignore: must_be_immutable
class UpdateDialog {
  BuildContext context;
  bool needHoldOn;
  late BookingProvider bookingProvider;
  late String date,
      type,
      price,
      myUserName,
      time,
      workerName,
      text,
      treatmentDuration;
  String todayOrTomorrow = '', day = '', stringDay = '', onHoldText = '';
  bool startLoading = false;
  Booking oldBooking;
  NavigatorState navigator;
  UpdateDialog(
      {required this.context,
      required this.oldBooking,
      required this.navigator,
      required this.needHoldOn});

  Future<dynamic> confirmBody() {
    bookingProvider = context.read<BookingProvider>();

    if (DateFormat('dd-MM-yyyy').format(BookingProvider.booking.bookingDate) ==
        DateFormat('dd-MM-yyyy')
            .format(DateTime.now().add(Duration(days: 1)))) {
      todayOrTomorrow = translate("tomorrow");
    }
    if (DateFormat('dd-MM-yyyy').format(BookingProvider.booking.bookingDate) ==
        DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      todayOrTomorrow = translate("today");
    }
    date = DateFormat('dd-MM-yyyy').format(BookingProvider.booking.bookingDate);
    time = DateFormat('HH:mm').format(BookingProvider.booking.bookingDate);
    final treatment = BookingProvider.workers[BookingProvider.workerPhone]!
        .treatments[BookingProvider.treatmentName]!;
    type = BookingProvider.treatmentName;
    price = treatment.priceToString();
    treatmentDuration = durationToString(
        Duration(minutes: BookingProvider.booking.treatment.totalMinutes));
    workerName = SettingsData.workers[BookingProvider.workerPhone]!.name;
    day = weekDays[BookingProvider.booking.bookingDate.weekday];
    myUserName = BookingProvider.booking.customerName;
    stringDay =
        todayOrTomorrow != "" ? todayOrTomorrow : translate("day") + " " + day;
    onHoldText = translate("bookingNeedConfirmation");
    UserData.getPermission() == 0
        ? text =
            "${translate('updateForNewDateQuestion')} $date \n${translate('at')}: $time, ${translate('to')} $workerName ?\n ${translate('treatmentType')}: $type | ${translate('price')}: $price | ${translate('time')}: $treatmentDuration."
        : text =
            "${translate('updateBookingForQuestion')} $myUserName ${translate('in')} $date \n${translate('at')}: $time ${translate('to')} $workerName ?\n ${translate('treatmentType')}: $type | ${translate('price')}: $price | ${translate('time')}: $treatmentDuration.";
    return genralDialog(
      context: context,
      title: translate('hey') + ' ' + UserData.user.name + ',',
      content: Text(
        needHoldOn ? text + 'ֿ\n\n' + onHoldText : text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // remove the selection
            UiManager.updateUi(
                context: context,
                perform: Future((() => BookingProvider.setTimeIndex(-1))));
            navigator.pop("CANCLE");
          },
          child: Text(translate('no')),
        ),
        TextButton(
          onPressed: () {
            navigator.pop('OK_UPDATE');
          },
          child: Text(translate('yes')),
        ),
      ],
    );
  }
}
