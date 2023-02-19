import 'package:flutter/material.dart';
import 'package:management_system_app/providers/booking_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/current_date_card.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/current_time_card.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/type_picker.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/treatments.dart';
import 'package:provider/provider.dart';

import '../../../utlis/string_utlis.dart';
import '../../animations/enter_animation.dart';

// ignore: must_be_immutable
class ManuallyBookingSheet extends StatelessWidget {
  final BuildContext ancestorContext;
  int spareDuration;
  late BookingProvider bookingProvider;
  late DateTime? date;
  ManuallyBookingSheet(
      {super.key, this.spareDuration = 999, required this.ancestorContext});
  @override
  Widget build(BuildContext context) {
    //provider
    bookingProvider = context.watch<BookingProvider>();

    //date
    date = BookingProvider.booking.bookingDate;

    return CustomContainer(
        showBorder: false,
        child: EnterAnimation(
          child: booking(context),
          animate: BookingProvider.sheetOpen,
        ));
  }

  Widget booking(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrentDateCard(currentDate: BookingProvider.booking.bookingDate),
          CurrentTimeCard(time: BookingProvider.booking.bookingDate),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translate('pickType'),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                addTreatment(ancestorContext)
              ],
            ),
          ),
          TypePicker(
              duration: spareDuration, ancestorContext: this.ancestorContext),
        ],
      ),
    );
  }

  Widget addTreatment(BuildContext context) {
    return CustomContainer(
        margin: EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(ancestorContext).colorScheme.secondary,
        needImage: false,
        raduis: 40,
        padding: EdgeInsets.all(1),
        onTap: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => Treatments()));
        },
        child:
            Icon(Icons.edit, color: Theme.of(context).colorScheme.onSecondary));
  }
}
