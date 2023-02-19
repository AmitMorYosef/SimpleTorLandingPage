import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/check_box_option.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/booking_provider.dart';
import '../../../app_const/platform.dart';
import '../../../app_const/worker_scedule.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/user_data.dart';
import 'genral_dialog.dart';

// ignore: must_be_immutable
class SaveDialog {
  BuildContext context;
  bool needHoldOn;
  bool workerAction;
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

  NavigatorState navigator;

  SaveDialog(
      {required this.context,
      this.workerAction = false,
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
        todayOrTomorrow != "" ? todayOrTomorrow : translate('day ') + day;
    onHoldText = translate("bookingNeedConfirmation");
    text =
        "${translate('confirmInviteBooking')} $date \n${translate('at')}: $time,${translate('to')} $workerName ?\n ${translate('treatmentType')}: $type | ${translate('price')}: $price | ${translate('time')}: $treatmentDuration.";
    return genralDialog(
      context: context,
      title: translate('hey') + ' ' + UserData.user.name + ',',
      content: Column(
        children: [
          Text(
            needHoldOn ? text + "\n\n" + onHoldText : text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          isWeb || workerAction
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: CheckBoxOption(
                    option: translate('addToDeviceCalendar'),
                    onTrue: onTrue,
                  ),
                )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // remove the selection
            UiManager.updateUi(
                context: context,
                perform: Future((() => BookingProvider.setTimeIndex(-1))));
            navigator.pop('CANCLE');
          },
          child: Text(translate('no')),
        ),
        TextButton(
          onPressed: () async {
            navigator.pop('OK_${CheckBoxOption.selection}');
          },
          child: Text(translate('yes')),
        ),
      ],
    );
  }

  Future<bool> onTrue() async {
    var status = await Permission.calendar.status;
    if (status.isPermanentlyDenied) {
      return await genralDialog(
          context: context,
          title: translate('premissionDenide'),
          content: Text(
            translate('allwoDeviceCalendar'),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(translate('ok')))
          ]);
    }
    if (status.isDenied) {
      PermissionStatus newStatus = await Permission.calendar.request();
      return newStatus.isGranted;
    }
    return true;
  }
}
