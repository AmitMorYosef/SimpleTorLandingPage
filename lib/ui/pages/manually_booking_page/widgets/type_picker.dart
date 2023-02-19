import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/models/treatment_model.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/get_break_details.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/treatment_type_widget.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/booking_provider.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../models/booking_model.dart';
import '../../../../utlis/times_utlis.dart';

// ignore: must_be_immutable
class TypePicker extends StatelessWidget {
  final int duration;
  final BuildContext ancestorContext;

  TypePicker({super.key, this.duration = 999, required this.ancestorContext});

  late WorkerProvider workerProvider;
  late BookingProvider bookingProvider;
  Map<String, Treatment> treatments = {};
  @override
  Widget build(BuildContext context) {
    workerProvider = context.watch<WorkerProvider>();
    bookingProvider = context.read<BookingProvider>();
    treatments = WorkerData.worker.treatments;
    return typesList(context);
  }

  Widget typesList(BuildContext context) {
    List<Widget> typesWidgets = [];
    typesWidgets.add(breakCard());
    // while clicking "free time" the times are set to booking provider
    DateTime bookingTimeToCheck = DateTime(
        1970,
        1,
        1,
        BookingProvider.booking.bookingDate.hour,
        BookingProvider.booking.bookingDate.minute);
    treatments.forEach((name, treatment) {
      Booking booking =
          getFakeBookingToCheck(name, treatment, WorkerData.focusedDay);
      bool optionalTreatment = isOptionalTimeForBooking(
          WorkerData.worker, booking, bookingTimeToCheck);
      if (optionalTreatment) {
        typesWidgets.add(TreatmentTypeWidget(
            name: name,
            treatment: treatments[name]!,
            ancestorContext: this.ancestorContext));
      }
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: typesWidgets,
      ),
    );
  }

  Widget breakCard() {
    return CustomContainer(
      margin: EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(ancestorContext).colorScheme.secondary,
      needImage: false,
      raduis: 40,
      padding: EdgeInsets.all(0),
      opacity: BookingProvider.isBreak ? 1 : 0.5,
      onTap: () async {
        if (!BookingProvider.isBreak) {
          await UiManager.updateUi(
              context: ancestorContext,
              perform: Future((() => BookingProvider.setBreak(true))));
          await GetBreakDetails().addBreakFields(ancestorContext);
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: AutoSizeText(
            translate("break"),
            style: Theme.of(ancestorContext)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 17),
          ),
        ),
      ),
    );
  }
}
