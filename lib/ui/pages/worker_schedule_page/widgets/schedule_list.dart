import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/models/break_model.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/schedule_page/schedule_page.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/bad_duration_widget.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/break.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/task.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/application_general.dart';
import '../../../../app_const/worker_scedule.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../models/booking_model.dart';
import '../../../../models/worker_model.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../providers/worker_provider.dart';
import '../../../../utlis/times_utlis.dart';
import '../../../../utlis/worker_scedule_utilis.dart';
import '../../../general_widgets/custom_widgets/custom_divider.dart';
import '../../settings_page/pages/schedule_page/widgets/vacations_page/vacations.dart';
import '../../settings_page/pages/schedule_page/widgets/work_time.dart';
import 'free_time.dart';

// ignore: must_be_immutable
class ScheduleList extends StatelessWidget {
  final BuildContext ancestorContext;
  late WorkerProvider workerProvider;
  late BookingProvider bookingProvider;
  late SettingsProvider settingsProvider;
  late String focusedDate, text;
  late BuildContext context;
  late int hours, minutes;
  late String weekDay;
  late List<Color> bookingColors = [];
  /*detemind when every event happen - used when worker wants to add a break*/
  static List<DateTime> eventsTimes = [];
  /*detemind the end of work  - used when worker wants to add a break*/
  static DateTime endOfWorkTimes = DateTime(0);
  static Map<String, Color> bookingSavedColors = {
    // "1": Colors.pink,
    // "13": Colors.purple,
    // "12": Colors.yellow,
    // "14": Colors.red,
    // "15": Colors.green,
    // "16": Colors.brown,
    // "167": Colors.amber,
    // "17": Colors.blueGrey,
    // "18": Colors.cyan,
    // "19": Colors.cyanAccent,
    // "198": Colors.deepOrange,
    // "145": Colors.indigo,
    // "1354": Colors.lightGreen,
    // "153": Colors.deepPurpleAccent,
  }; // save the color for each booking

  ScheduleList({super.key, required this.ancestorContext});
  void removeTakenColors() {
    bookingSavedColors.values.forEach((color) {
      bookingColors.remove(color);
    });
  }

  @override
  Widget build(BuildContext _context) {
    context = _context;
    workerProvider = context.watch<WorkerProvider>();
    eventsTimes = [];
    endOfWorkTimes = DateTime(0);
    bookingColors = [...sceduleColors];
    removeTakenColors();
    workerProvider = context.read<WorkerProvider>();

    bookingProvider = context.read<BookingProvider>();
    settingsProvider = context.read<SettingsProvider>();
    focusedDate = DateFormat('dd-MM-yyyy').format(WorkerData.focusedDay);
    weekDay = DateFormat('EEEE').format(WorkerData.focusedDay).toLowerCase();

    return Container();
  }

  RenderObjectWidget scheduleList() {
    // check passed day
    if (WorkerData.focusedDay.isBefore(setToMidNight(DateTime.now()))) {
      Iterable<Widget>? iterable = passedDaySchdule();
      if (iterable == null) {
        return SliverList(
            delegate: SliverChildBuilderDelegate(childCount: 1, (_, __) {
          return SizedBox();
        }));
      }
      Iterator<Widget> eventsIterator = iterable.iterator;
      List<Widget> eventsList = [];

      return SliverList(
          key: Key(Uuid().v1()),
          delegate:
              SliverChildBuilderDelegate(childCount: 300, (context, index) {
            bool hasVal = eventsIterator.moveNext();
            if (hasVal) {
              /* need to save the element for swip up 
              (the generator val disappeard after get current)*/
              eventsList.add(eventsIterator.current);
            }
            if (index == eventsList.length) {
              // create spase at the end of the list
              return SizedBox(
                height: 80,
              );
            } else if (index > eventsList.length) {
              return SizedBox();
            }
            return eventsList[index];
          }));
    }

    Iterable<Widget>? iterable = schdule();
    if (iterable == null || iterable.isEmpty) {
      String message = translate("noShiftsForToday");
      String todayStr = DateFormat('dd-MM-yyyy').format(WorkerData.focusedDay);
      // day is vacation
      if (WorkerData.worker.vacations.keys.contains(todayStr)) {
        message = translate("freeDay");
      }
      // day is goliday
      if (WorkerData.worker.closeScheduleOnHolidays &&
          isHoliday(WorkerData.worker, WorkerData.focusedDay)) {
        logger.d("Holiday is free day for this worker -> don't generate times");
        //return hours;
        message = translate("HolidayFreeDay");
      }
      return SliverToBoxAdapter(
          key: Key(Uuid().v1()),
          child: Container(
            alignment: Alignment.center,
            height: 200,

            padding: EdgeInsets.symmetric(horizontal: 70),
            width: gWidth,
            //color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.free_cancellation_rounded,
                  color: Colors.grey,
                  size: 35,
                ),
                Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomContainer(
                    onTap: () => changeWorkBtn(todayStr),
                    padding: EdgeInsets.all(10),
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text(translate("pressToChange"),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 15))),
              ],
            ),
          ));
    }
    // SliverList(
    //     key: Key(Uuid().v1()),
    //     delegate: SliverChildBuilderDelegate(childCount: 1, (context, index) {
    //       return Container(height: ,);
    //     }));
    Iterator<Widget> eventsIterator = iterable.iterator;
    List<Widget> eventsList = [];

    return SliverList(
        key: Key(Uuid().v1()),
        delegate: SliverChildBuilderDelegate(childCount: 300, (context, index) {
          bool hasVal = eventsIterator.moveNext();
          if (hasVal) {
            /* need to save the element for swip up 
              (the generator val disappeard after get current)*/
            eventsList.add(eventsIterator.current);
          }
          if (index == eventsList.length) {
            // create spase at the end of the list
            return SizedBox(
              height: 80,
            );
          } else if (index > eventsList.length) {
            return SizedBox();
          }
          return eventsList[index];
        }));
  }

  void changeWorkBtn(String todayStr) {
    // vacation -> change vactions days
    if (WorkerData.worker.vacations.keys.contains(todayStr)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Vacations()));

      return;
    }
    // holiday change workOnHolidays status
    else if (WorkerData.worker.closeScheduleOnHolidays &&
        isHoliday(WorkerData.worker, WorkerData.focusedDay)) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => SettingsSchedulePage()));
      return;
    }
    // finally change work time status
    else {
      Map<String, List<String>> map = {};
      WorkerData.worker.workTime.keys.forEach((key) {
        map[key] = [...WorkerData.worker.workTime[key]!];
      });

      Navigator.push(context,
          MaterialPageRoute(builder: (_) => WorkTime(initialWorkTime: map)));
      return;
    }
  }

  Color generateUnicColor() {
    if (bookingColors.length == 0) {
      // re-fill the colors list
      bookingColors = [...sceduleColors];
    }
    int colorIndex = Random().nextInt(bookingColors.length);
    Color color = bookingColors[colorIndex];
    bookingColors.removeAt(colorIndex);
    return color;
  }

  Map<String, Map<String, dynamic>> get toadyBookings {
    Map<String, Map<String, dynamic>> todayBookings = {};
    if (WorkerData.worker.bookingObjects.keys.contains(focusedDate)) {
      WorkerData.worker.bookingObjects[focusedDate]!.forEach((key, booking) {
        DateTime startTime = booking.bookingDate;
        Color? bookingColor = bookingSavedColors[booking.bookingId];
        if (booking.treatment.times.length > 1 && bookingColor == null) {
          bookingColor = generateUnicColor();
          bookingSavedColors[booking.bookingId] = bookingColor;
        }
        booking.treatment.times.forEach((timeIndex, timeData) {
          String time = DateFormat('HH:mm').format(startTime);
          todayBookings[time] = {
            "booking": booking,
            "timeIndex": timeIndex,
            "title": timeData['title'] == '' ? '' : ' - ${timeData['title']}',
            'color': WorkerData.worker.showSceduleColors ? bookingColor : null
          };
          eventsTimes.add(setTo1970(startTime));
          // finish the treatment
          startTime = startTime.add(Duration(minutes: timeData['duration']!));
          // addint the break after the treatment
          startTime = startTime.add(Duration(minutes: timeData['break']!));
        });
      });
    }

    return todayBookings;
  }

  Iterable<Widget>? getEvents(
      List<int> eventTimeIndex,
      List<DateTime> forbbidenTimes,
      Map<String, Map<String, dynamic>> todayBookings,
      Map<DateTime, BreakModel> breaks,
      {bool includeDevider = true,
      bool includeShouldSkip = true,
      DateTime? eventsFrom,
      DateTime? eventsTill}) sync* {
    bool firstAfterSkipping = false;
    for (eventTimeIndex[0];
        eventTimeIndex[0] < forbbidenTimes.length;
        eventTimeIndex[0] += 2) {
      DateTime eventTime = forbbidenTimes[eventTimeIndex[0]];
      if (eventsFrom != null && eventTime.isBefore(eventsFrom)) {
        continue;
      }
      if (eventsTill != null && !eventTime.isBefore(eventsTill)) {
        break;
      }
      if (includeShouldSkip && !shouldSkip(eventTime, focusedDate)) {
        // if shoulden't skip no need to pass over the event (sorted list)
        break;
      }
      String strPointerWork = DateFormat('HH:mm').format(eventTime);
      // has booking event
      bool hasBookingEvent = todayBookings.keys.contains(strPointerWork) &&
          todayBookings[strPointerWork] != null;
      // has break event
      bool hasBreakEvent = breaks[eventTime] != null;
      // put the first devider above "passed events"
      if ((!firstAfterSkipping && (hasBookingEvent || hasBreakEvent)) &&
          includeDevider) {
        yield CustomDivider(
          txt: Text(
            translate('passedBookings'),
          ),
        );
        firstAfterSkipping = true;
      }
      if (hasBookingEvent) {
        String segmentKey = todayBookings[strPointerWork]!['timeIndex'];
        int duration = (todayBookings[strPointerWork]!['booking'] as Booking)
            .treatment
            .times[segmentKey]!['duration']!;
        // adding the passed booking
        yield Task(
            endSection: eventTime.add(Duration(minutes: duration)),
            startSection: eventTime,
            color: todayBookings[strPointerWork]!['color'],
            sectionTitle: todayBookings[strPointerWork]!['title'],
            ancestorContext: context,
            timeIndex: todayBookings[strPointerWork]!['timeIndex'],
            booking: todayBookings[strPointerWork]!['booking']!);
      } else if (hasBreakEvent) {
        // adding the passed break
        BreakModel breakModel = breaks[eventTime]!;
        yield Break(
          breakModel: breakModel,
          ancetorContext: context,
        );
      }
    }
    // first devider added - adding the secont one
    if ((firstAfterSkipping) && includeDevider) {
      firstAfterSkipping = false;
      yield CustomDivider(
        txt: Text(translate('nextBookings')),
      );
    }
  }

  Iterable<Widget>? schdule() sync* {
    eventsTimes = [];
    endOfWorkTimes = DateTime(0);
    //List<Widget> dayTimes = [];
    WorkerModel worker = WorkerData.worker;
    int index = 0;
    if (!worker.workTime.keys.contains(weekDay)) return;
    if (worker.closeScheduleOnHolidays &&
        isHoliday(worker, WorkerData.focusedDay)) {
      logger.d("Holiday is free day for this worker -> don't generate times");
      //return hours;
      return;
    }
    // work in this day generally
    // Duration shortBookingTime = Duration(minutes: worker.shortBookingTime);
    Map<String, Map<String, dynamic>> todayBookings = toadyBookings;
    List<DateTime> work = convertStringToTime(worker.workTime[weekDay]);
    /*"getTodayBreaks" add the relevant breaks to the eventsTime list*/
    Map<DateTime, BreakModel> breaks =
        getTodayBreaks(focusedDate, worker.breaks);
    List<DateTime> vacations =
        convertStringToTime(worker.vacations[focusedDate]);
    List<DateTime> takenHoures = alreadyTakenHoures(worker, focusedDate);
    List<DateTime> forbbidenTimes = (vacations +
        takenHoures +
        getTodayListOfBreaks(focusedDate, worker.breaks));
    // all day free
    if (worker.vacations[focusedDate] != null && vacations.length == 0) {
      logger.d("Free day don't generate times");
      return;
    }

    work.sort();
    forbbidenTimes.sort();
    EventTyps previusEventType = EventTyps.block;
    DateTime currentTime =
        getTimeDevideByFive(DateTime.now(), inCheckFormat: true);
    logger.d('Scedule forbbidenTimes length: ${forbbidenTimes.length}');
    // add the passed events to the list
    List<int> eventTimeIndex = [0];
    Iterable<Widget>? passedEvents = getEvents(
      eventTimeIndex,
      forbbidenTimes,
      todayBookings,
      breaks,
    );
    if (passedEvents != null) {
      for (Widget widget in passedEvents) {
        yield widget;
      }
    }
    DateTime? lastEnd;
    for (var j = 0; j < work.length; j += 2) {
      DateTime pointerWork = work[j];
      DateTime endWork = work[j + 1];
      if (j > 1) {
        lastEnd = work[j - 1]; // the previus end
      }
      DateTime? startBadTime;
      endOfWorkTimes = endWork; // save the end of the block for "break events"
      if (shouldSkip(pointerWork, focusedDate)) {
        switch (
            durationStrikings(currentTime, currentTime, pointerWork, endWork)) {
          case 'BEFORE': // current is later
            logger.d("Scedule alg duration status - BEFORE");
            continue;
          case 'AFTER': // current is passed
            logger.d("Scedule alg duration status - AFTER");
            break;
          case 'STRIKE': // current in this section
            logger.d("Scedule alg duration status - STRIKE");
            break;
        }
        pointerWork = currentTime;
        /* in case the last forbidden started before now and 
        end after - jump to the end of it */
        if (eventTimeIndex[0] - 1 > 0 &&
            eventTimeIndex[0] - 1 < forbbidenTimes.length &&
            forbbidenTimes[eventTimeIndex[0] - 1].isAfter(currentTime)) {
          pointerWork = forbbidenTimes[eventTimeIndex[0] - 1];
        }
      }
      // if worker changed the work times - still deploy today events
      passedEvents = getEvents(
          eventTimeIndex, forbbidenTimes, todayBookings, breaks,
          includeDevider: false,
          includeShouldSkip: false,
          eventsFrom: lastEnd, // at the beggining null (start from last event)
          eventsTill: pointerWork);
      if (passedEvents != null) {
        for (Widget widget in passedEvents) {
          yield widget;
        }
      }

      while (pointerWork.isBefore(endWork)) {
        index++;
        if (index > 500) return;
        String strPointerWork = DateFormat('HH:mm').format(pointerWork);
        bool hasBooking = todayBookings.keys.contains(strPointerWork);
        bool hasBreak = breaks.containsKey(pointerWork);

        /* if there is a "bad time" that end now - adding the object */
        if (startBadTime != null && (hasBooking || hasBreak)) {
          yield BadDurationWidget(
            start: startBadTime,
            end: pointerWork,
          );
          startBadTime = null;
        }

        // there is a booking in this time - put this in scedule
        if (hasBooking) {
          String segmentKey = todayBookings[strPointerWork]!['timeIndex'];
          int duration = (todayBookings[strPointerWork]!['booking'] as Booking)
              .treatment
              .times[segmentKey]!['duration']!;
          if (todayBookings[strPointerWork] != null) {
            previusEventType = EventTyps.block;
            // prevent ui crush when worker delete
            // booking
            /*detemind the end of work  - used when worker wants to add a break*/
            yield Task(
                endSection: pointerWork.add(Duration(minutes: duration)),
                startSection: pointerWork,
                color: todayBookings[strPointerWork]!['color'],
                sectionTitle: todayBookings[strPointerWork]!['title'],
                ancestorContext: context,
                timeIndex: todayBookings[strPointerWork]!['timeIndex'],
                booking: todayBookings[strPointerWork]!['booking']);
          }

          // jumping to the end of the event - more efficency

          pointerWork = pointerWork.add(Duration(minutes: duration));
        }

        // there is a break in this time - put this in scedule
        else if (hasBreak) {
          previusEventType = EventTyps.block;
          // break adding
          BreakModel breakModel = breaks[pointerWork]!;
          /*detemind the end of work  - used when worker wants to add a break*/
          yield Break(
            breakModel: breakModel,
            ancetorContext: context,
          );
          // jumping to the end of the event - more efficency
          Duration breakDuration = breakModel.duration;
          pointerWork = pointerWork // prevent infinity loop in case of bug
              .add(Duration(minutes: max(breakDuration.inMinutes, 5)));
        }
        // there is no event to add - "free time business login"
        else {
          // check if it "bad time" or worker can set a booking in this time
          bool possibleTimeToSetBooking = isOptionalTimeForTreatment(
              pointerWork,
              work,
              vacations,
              breaks.keys.toList(),
              takenHoures,
              forbbidenTimes);
          // dont mark as bad time if no treatment exist
          bool emptyTreatments = WorkerData.worker.treatments.length == 0;
          // optional time to set a booking
          if (possibleTimeToSetBooking || emptyTreatments) {
            previusEventType = EventTyps.freeTime;
            startBadTime =
                null; // only free times will lead to block of start to be with block of end
            yield FreeTime(
                time: pointerWork, ancestorContext: this.ancestorContext);
            pointerWork = pointerWork.add(Duration(minutes: 5));
          }
          // "bad time"
          else {
            // BadTime have to be between blocks
            if (startBadTime == null && previusEventType == EventTyps.block) {
              // start "bad time" duration
              startBadTime = pointerWork;
            }
            pointerWork = pointerWork.add(Duration(minutes: 5));
          }
        }
      }
      /* end of work is also block have to be here in case the time 
      is started in this passage of the loop */
      if (startBadTime != null && pointerWork == endWork) {
        yield BadDurationWidget(
          start: startBadTime,
          end: pointerWork,
        );
        startBadTime = null;
      }
    }

    if (work.length > 1) {
      lastEnd = work.last; // the previus end
    }
    passedEvents = getEvents(
        eventTimeIndex, forbbidenTimes, todayBookings, breaks,
        includeDevider: false,
        includeShouldSkip: false,
        eventsFrom: work.length == 0 ? null : lastEnd,
        eventsTill: DateTime.now().add(Duration(days: 1)));
    if (passedEvents != null) {
      for (Widget widget in passedEvents) {
        yield widget;
      }
    }
  }

  Iterable<Widget>? passedDaySchdule() sync* {
    eventsTimes = [];
    endOfWorkTimes = DateTime(0);
    //List<Widget> dayTimes = [];
    WorkerModel worker = WorkerData.worker;
    if (!worker.workTime.keys.contains(weekDay)) return;
    // work in this day generally
    // Duration shortBookingTime = Duration(minutes: worker.shortBookingTime);
    /*"getTodayBreaks" add the relevant breaks to the eventsTime list*/
    Map<String, Map<String, dynamic>> todayBookings = toadyBookings;
    List<DateTime> takenHoures = alreadyTakenHoures(worker, focusedDate);
    takenHoures.sort();
    if (takenHoures.length == 0) {
      yield Container(
        alignment: Alignment.center,
        height: 200,
        padding: EdgeInsets.symmetric(horizontal: gWidth * 0.1),
        //width: gWidth * 0.6,
        //color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.free_cancellation_rounded,
              color: Colors.grey,
              size: 35,
            ),
            Text(
              translate("noTreatmentsForToday"),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 25),
            ),
          ],
        ),
      );
    }
    // add the passed events to the list
    for (int eventTimeIndex = 0;
        eventTimeIndex < takenHoures.length;
        eventTimeIndex += 2) {
      DateTime eventTime = takenHoures[eventTimeIndex];
      String strPointerWork = DateFormat('HH:mm').format(eventTime);
      // has booking event
      bool hasBookingEvent = todayBookings.keys.contains(strPointerWork) &&
          todayBookings[strPointerWork] != null;
      if (hasBookingEvent) {
        String segmentKey = todayBookings[strPointerWork]!['timeIndex'];
        int duration = (todayBookings[strPointerWork]!['booking'] as Booking)
            .treatment
            .times[segmentKey]!['duration']!;
        // adding the passed booking
        yield Task(
            endSection: eventTime.add(Duration(minutes: duration)),
            startSection: eventTime,
            isPassedTask: true,
            color: todayBookings[strPointerWork]!['color'],
            sectionTitle: todayBookings[strPointerWork]!['title'],
            ancestorContext: context,
            timeIndex: todayBookings[strPointerWork]!['timeIndex'],
            booking: todayBookings[strPointerWork]!['booking']!);
      }
    }
  }
}
