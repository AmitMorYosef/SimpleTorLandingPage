import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/providers/booking_provider.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../manually_booking_page/manually_booking.dart';

// ignore: must_be_immutable
class FreeTime extends StatelessWidget {
  final BuildContext ancestorContext;
  late String text;
  late int hours, minutes;
  int spareDuration;
  DateTime time;
  late WorkerProvider workerProvider;
  late BookingProvider bookingProvider;
  late SettingsProvider settingsProvider;
  FreeTime(
      {super.key,
      this.spareDuration = 999,
      required this.time,
      required this.ancestorContext});

  @override
  Widget build(BuildContext context) {
    workerProvider = context.read<WorkerProvider>();
    bookingProvider = context.read<BookingProvider>();
    settingsProvider = context.read<SettingsProvider>();
    text = DateFormat('HH:mm').format(time);
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: GestureDetector(
        onTap: () async {
          if (!await isNetworkConnected()) {
            notNetworkConnectedToast(context);
            return;
          }
          // if (WorkerData.worker.treatments.isEmpty) {
          //   CustomToast(context: context, msg: "אין טיפולים זמינים").init();
          //   return;
          // }
          UiManager.updateUi(
              context: context,
              perform: Future((() {
                BookingProvider.setup();
                BookingProvider.setDate(WorkerData.focusedDay);
                BookingProvider.booking.workerId = WorkerData.worker.phone;
                BookingProvider.workerPhone = WorkerData.worker.phone;
                BookingProvider.setTreatmentName('');
                DateTime date = WorkerData.focusedDay;
                minutes = int.parse(twoDigits(int.parse(text[3] + text[4])));
                hours = int.parse(twoDigits(int.parse(text[0] + text[1])));
                BookingProvider.setDate(
                    DateTime(date.year, date.month, date.day, hours, minutes));
              })));
          BookingProvider.setSheetOpen(false);
          SlidingBottomSheet(
                  context: context,
                  sheet: ManuallyBookingSheet(
                      spareDuration: spareDuration,
                      ancestorContext: this.ancestorContext),
                  size: 1)
              .showSheet();
        },
        child: Container(
          height: gHeight * 0.05,
          width: gWidth,
          decoration: BoxDecoration(
            border: GradientBoxBorder(
              gradient: LinearGradient(colors: [
                // Color(0xffFFFFFF).withOpacity(0.45),
                Color(0xffFFFFFF).withOpacity(0.15),
                Color(0x000000).withOpacity(0.1)
              ]),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(text), Icon(Icons.add)],
          )),
        ),
      ),
    );
  }

  String durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }
}
