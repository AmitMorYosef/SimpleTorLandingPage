import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/times_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/worker_scedule.dart';
import '../../../../models/worker_model.dart';
import '../../../../providers/booking_provider.dart';
import '../../../helpers/fonts_helper.dart';
import '../../../ui_manager.dart';

// ignore: must_be_immutable
class DatePicker {
  late BookingProvider bookingProvider;
  late DateTime? date, newDate;
  late String formatedDate;
  final DateTime initDate = DateTime.now();
  late DateTime currentDate = initDate;
  late DateTime finalDate;
  late String stringDate, day;
  int selectedIndex = -1;
  ScrollController scrollController = ScrollController();
  late bool tapped;
  late List<String> dates = [];
  WorkerModel? worker;
  BuildContext context;
  DatePicker({
    required this.context,
    required this.worker,
  });

  Widget picker() {
    bookingProvider = context.watch<BookingProvider>();
    if (this.worker == null) return SizedBox();
    finalDate = initDate.add(Duration(days: worker!.daysToAllowBookings));
    while (currentDate.isBefore(finalDate)) {
      String date = DateFormat('dd-MM-yyyy').format(currentDate);
      // this is holiday and worker dosen't work, skipping the day
      if (isHoliday(this.worker!, currentDate)) {
        currentDate = currentDate.add(Duration(days: 1));
        continue;
      }
      Map<String, List<String>> vacations = worker!.vacations;
      Map<String, List<String>> workTime = worker!.workTime;
      String weekDay = DateFormat('EEEE').format(currentDate).toLowerCase();

      if (workTime.containsKey(weekDay) && workTime[weekDay]!.length > 0) {
        if (!(vacations.containsKey(date) && vacations[date]!.length > 0) ||
            !vacationLongThenWork(workTime[weekDay], vacations[date])) {
          if (!dates.contains(date)) dates.add(date); // prevent double adding
          // if the clock return hour back in 00:59 and this opnen in 00:00
          // so the day adding will add only 23 hours (24 and back 1)..
        }
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          dates.length > 0
              ? Text(
                  translate('pickDate'),
                  style: FontsHelper().businessStyle(
                    currentStyle: Theme.of(context).textTheme.headlineSmall,
                  ),
                )
              : SizedBox(),
          dates.length == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    translate('noAvailableDates'),
                    style: FontsHelper().businessStyle(
                      currentStyle: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
              : dates.length == 0
                  ? SizedBox()
                  : datesList()
        ],
      ),
    );
  }

  bool vacationLongThenWork(List<String>? work, List<String>? vacation) {
    DateTime startWork = DateFormat('HH:mm').parse(work![0]);
    DateTime startVacation = DateFormat('HH:mm').parse(vacation![0]);
    DateTime endWork = DateFormat('HH:mm').parse(work[work.length - 1]);
    DateTime endVacation =
        DateFormat('HH:mm').parse(vacation[vacation.length - 1]);
    return !startWork.isBefore(startVacation) && !endVacation.isBefore(endWork);
  }

  Widget datesList() {
    return SizedBox(
      height: gHeight * .15,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  if (!BookingProvider.booking.bookingDate.isAtSameMomentAs(
                      DateFormat('dd-MM-yyyy').parse(dates[index]))) {
                    UiManager.updateUi(
                        context: context,
                        perform: Future(() => {
                              BookingProvider.setDate(
                                  DateFormat('dd-MM-yyyy').parse(dates[index])),
                              BookingProvider.setTimeIndex(-1)
                            }));
                  }
                },
                child: dateCard(index));
          }),
    );
  }

  Widget dateCard(int index) {
    stringDate = dates[index];
    day = '';
    if (dates[index] ==
        DateFormat('dd-MM-yyyy')
            .format(DateTime.now().add(Duration(days: 1)))) {
      day = translate('tomorrow');
    }
    if (dates[index] == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      day = translate('today');
    }
    if (day == '')
      day = translate(
          weekDays[DateFormat('dd-MM-yyyy').parse(dates[index]).weekday]);

    tapped = dates[index] ==
        DateFormat('dd-MM-yyyy').format(BookingProvider.booking.bookingDate);

    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Opacity(
                opacity: tapped ? 1 : 0.5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Theme.of(context).colorScheme.secondary),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AutoSizeText(
                        stringDate + '\n' + day,
                        textAlign: TextAlign.center,
                        style: FontsHelper().businessStyle(
                          currentStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ]);
  }
}
