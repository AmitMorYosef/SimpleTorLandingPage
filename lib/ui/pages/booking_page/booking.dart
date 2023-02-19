import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/pages/booking_page/widgets/date_picker.dart';
import 'package:simple_tor_web/ui/pages/booking_page/widgets/time_picker.dart';
import 'package:simple_tor_web/ui/pages/booking_page/widgets/treatment_picker.dart';
import 'package:simple_tor_web/ui/pages/booking_page/widgets/worker_picker.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_statics.dart/worker_data.dart';
import '../../../models/booking_model.dart';
import '../../../models/worker_model.dart';
import '../../../providers/booking_provider.dart';
import '../../animations/enter_animation.dart';

// ignore: must_be_immutable
class BookingSheet extends StatelessWidget {
  bool isUpdateSheet;
  Booking? oldBooking;
  final double sheetHeight = gHeight * .7;
  final fadeDuration = Duration(milliseconds: 400);
  late int timeIndex;
  late BookingProvider bookingProvider;

  late DateTime? date;
  late String treatmentName, workerPhone;
  late Map<String, WorkerModel> workers;
  BuildContext ancestorContext;
  bool workerUpdate;
  bool workerSheet;

  BookingSheet(
      {super.key,
      this.workerUpdate = false,
      this.isUpdateSheet = false,
      this.workerSheet = false,
      this.oldBooking = null,
      required this.ancestorContext});

  @override
  Widget build(BuildContext context) {
    // sheetHeight =
    //     gHeight * 0.63 * pow(MediaQuery.of(context).textScaleFactor, 1);

    //provider
    bookingProvider = context.watch<BookingProvider>();

    //indexs
    workerPhone = BookingProvider.workerPhone;
    treatmentName = BookingProvider.treatmentName;
    timeIndex = BookingProvider.timeIndex;

    //date
    date = BookingProvider.booking.bookingDate;
    return Container(
        alignment: Alignment.topCenter,
        height: sheetHeight,
        width: gWidthOriginal,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: BookingProvider.sheetOpen
              ? booking(context)
              : EnterAnimation(paddingFromTop: 0, child: booking(context)),
        ));
  }

  Widget booking(BuildContext context) {
    BookingProvider.setSheetOpen(true);
    if (!workerUpdate) {
      if (this.isUpdateSheet) {
        UiManager.updateUi(
            context: context,
            perform: Future((() => BookingProvider.setWorkerPhone(
                newWorkerPhone: workerPhone, needNotify: false))));
      }
      workers = BookingProvider.workers;
    } else {
      workers = {WorkerData.worker.phone: WorkerData.worker};
      UiManager.updateUi(
          context: context,
          perform: Future((() => BookingProvider.setWorkerPhone(
              newWorkerPhone: WorkerData.worker.phone, needNotify: false))));
    }
    bool showTime = BookingProvider.workerPhone != '' &&
        !BookingProvider.booking.bookingDate.isAtSameMomentAs(DateTime(0)) &&
        BookingProvider.treatmentName != '';
    bool showDate = BookingProvider.workerPhone != '' &&
        BookingProvider.treatmentName != '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            alignment: Alignment.center,
            height: gHeight * .14,
            child: WorkerPicker(context: context, workers: workers).picker()),
        BookingProvider.workerPhone != ''
            ? Container(
                alignment: Alignment.center,
                height: gHeight * .2,
                child: TypePicker(
                        context: context, worker: BookingProvider.getWorker)
                    .picker(),
              )
            : SizedBox(),
        showDate
            ? Container(
                alignment: Alignment.center,
                height: gHeight * .2,
                child: DatePicker(
                  context: context,
                  worker: BookingProvider.getWorker,
                ).picker(),
              )
            : SizedBox(),
        showTime
            ? Container(
                alignment: Alignment.center,
                height: gHeight * .14,
                child: TimePicker(
                    context: context,
                    workerAction: workerUpdate,
                    workerSheet: workerSheet,
                    ancestorContext: ancestorContext,
                    navigator: Navigator.of(ancestorContext),
                    isUpdateSheet: this.isUpdateSheet,
                    oldBooking: this.oldBooking,
                    worker: BookingProvider.getWorker),
              )
            : SizedBox(),
      ],
    );
  }
}
