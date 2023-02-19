import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_tor_web/providers/booking_provider.dart';
import 'package:provider/provider.dart';

import '../../../helpers/fonts_helper.dart';

class TimeWidget extends StatelessWidget {
  final DateTime time;
  final int indexInTimesList;
  late BookingProvider bookingProvider;
  TimeWidget({super.key, required this.time, required this.indexInTimesList});

  @override
  Widget build(BuildContext context) {
    // listener in the current booking - to change color
    bookingProvider = context.read<BookingProvider>();
    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Opacity(
                opacity: this.indexInTimesList == BookingProvider.timeIndex
                    ? 1
                    : 0.5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Theme.of(context).colorScheme.secondary),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AutoSizeText(DateFormat('HH:mm').format(this.time),
                          style: FontsHelper().businessStyle(
                            currentStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontSize: 17),
                          )),
                    ),
                  ),
                ),
              )),
        ]);
  }
}
