import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';

import '../../../../app_const/worker_scedule.dart';
import '../../../../utlis/string_utlis.dart';

// ignore: must_be_immutable
class CurrentDateCard extends StatelessWidget {
  final DateTime currentDate;
  late String day = '';
  CurrentDateCard({super.key, required this.currentDate});

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd-MM-yyyy').format(currentDate);
    String stringDate = date;
    if (date ==
        DateFormat('dd-MM-yyyy')
            .format(DateTime.now().add(Duration(days: 1)))) {
      day = translate('tomorrow');
    }
    if (date == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      day = translate('today');
    }
    if (day == '')
      day = translate('day') +
          " " +
          translate(weekDays[DateFormat('dd-MM-yyyy').parse(date).weekday]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            border: GradientBoxBorder(
              gradient: LinearGradient(colors: [
                Color(0xffFFFFFF).withOpacity(0.15),
                Color(0x000000).withOpacity(0.1)
              ]),
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Theme.of(context).colorScheme.secondary),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              stringDate + '\n' + day,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
