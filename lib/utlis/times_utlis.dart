import 'dart:math';

import 'package:intl/intl.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/models/break_model.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/schedule_list.dart';

import '../app_const/worker_scedule.dart';
import '../models/booking_model.dart';
import '../models/treatment_model.dart';

String durationStrikings(
    DateTime start, DateTime end, DateTime startTime, DateTime endTime) {
  /* get time in 1970 format
   time should be either before or after - not in between */
  bool bothBefore = startTime.isBefore(start) && !endTime.isAfter(start);
  bool bothAfter = !startTime.isBefore(end) && endTime.isAfter(end);
  if (bothBefore) return "BEFORE";
  if (bothAfter) return "AFTER";
  return "STRIKE";
}

bool shouldSkip(DateTime pointerWork, String bookingDate, {bool? todayCheck}) {
  String currentTime = DateFormat('HH:mm').format(DateTime.now());
  bool isToday = todayCheck ??
      bookingDate == DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool timePessed =
      pointerWork.isBefore(DateFormat('HH:mm').parse(currentTime));

  return (isToday && timePessed);
}

Map<String, Map<String, dynamic>> generateTimeSegmentsMap(
    Booking booking, DateTime startTime) {
  /**
   get: booking
   return: map of the time segments with the start and duration ->
   {
    0 -> {
      'start': DateTime(),
      'duration': Duration(minutes:50)
    }
   }
   */
  Map<String, Map<String, dynamic>> timesSegments = {};
  DateTime lastTime = startTime;
  booking.treatment.times.forEach((timeIndex, timeData) {
    // adding the break before - start of the treatment
    timesSegments[timeIndex] = {
      'start': lastTime, //DateFormat('HH:mm').parse()
      'duration': Duration(minutes: timeData['duration']!),
    };
    // adding the time of the treatment
    lastTime = lastTime.add(Duration(minutes: timeData['duration']!));
    // addint the break after the treatment
    lastTime = lastTime.add(Duration(minutes: timeData['break']!));
  });
  return timesSegments;
}

int minutesToJumpOverForbbiden(
    List<int> forbiddenTimesPointers,
    Map<String, Map<String, dynamic>> timeSegments,
    List<DateTime> forbbidenTimes) {
  // set the value to return
  int minutesToJump = 0; // of this 0 - > allowed time

  // organize the list pf the times and the start val
  int segmentIndex = 0;
  List<Map<String, dynamic>> segments = timeSegments.values.toList();
  // the forbbiden pointers have the same length as timeSegments.values

  // pass over the pointers to firbbiden times
  forbiddenTimesPointers.forEach((pointer) {
    // pass over the vacations & taken houres & breakes by pointers
    DateTime startSegment = segments[segmentIndex]['start'];
    DateTime endSegment = startSegment.add(segments[segmentIndex]['duration']);

    for (pointer; pointer < forbbidenTimes.length; pointer += 2) {
      if (pointer + 1 >= forbbidenTimes.length) break;
      String status = durationStrikings(forbbidenTimes[pointer],
          forbbidenTimes[pointer + 1], startSegment, endSegment);
      if (status == 'STRIKE') {
        // if strike the end of forbbiden have to be after start of segment
        int currentdiffernce =
            forbbidenTimes[pointer + 1].difference(startSegment).inMinutes;
        // set the jump to the heiget option
        minutesToJump = max(minutesToJump, currentdiffernce);
        break;
      }

      if (status == 'BEFORE') break;
    }
    // passing to the next time segment
    segmentIndex += 1;
  });
  return minutesToJump;
}

void addMinutesToAllSegments(
    Map<String, Map<String, dynamic>> timeSegments, int minutes) {
  /*
  get the map og the segments and minutes -> 
  adding the duration to all the segments
    */
  timeSegments.forEach((timeIndex, timeData) {
    timeData['start'] =
        (timeData['start'] as DateTime).add(Duration(minutes: minutes));
  });
}

Iterable<DateTime>? relevantHoures(WorkerModel? worker, Booking booking,
    {bool isUpdate = false,
    Booking? oldBooking = null,
    bool workerSheet = false}) sync* {
  if (worker == null) return;
  // all day free
  if (worker.closeScheduleOnHolidays &&
      isHoliday(worker, booking.bookingDate)) {
    logger.d("Holiday is free day for this worker -> don't generate times");
    //return hours;
    return;
  }
  // vars to make code cleaner
  String bookingDate = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
  // relevant times to calculate
  String weekDay = DateFormat('EEEE').format(booking.bookingDate).toLowerCase();
  List<DateTime> work = convertStringToTime(worker.workTime[weekDay]);
  List<DateTime> vacations = convertStringToTime(worker.vacations[bookingDate]);
  List<DateTime> breaks = getTodayListOfBreaks(bookingDate, worker.breaks);
  List<DateTime> takenHoures = alreadyTakenHoures(worker, bookingDate,
      isUpdate: isUpdate, oldBooking: oldBooking);
  List<DateTime> forbbidenTimes = vacations + takenHoures + breaks;

  // all day free
  if (worker.vacations[bookingDate] != null && vacations.length == 0) {
    logger.d("Free day don't generate times");
    //return hours;
    return;
  }

  forbbidenTimes.sort();
  work.sort(); // [8:00,13:00,14:00,21:00]
  // fill this list with 0 those will be the pointers on each time segments
  List<int> forbiddenTimesPointers =
      List.generate(booking.treatment.times.keys.length, (index) => 0);
  // current legal time (end with 0 or 5)
  DateTime currentTime =
      getTimeDevideByFive(DateTime.now(), inCheckFormat: true);
  // pass over the work times
  int i = 0;
  for (var j = 0; j < work.length; j += 2) {
    DateTime pointerWork = work[j];
    DateTime endWork = work[j + 1];
    // skipping to the current time
    if (shouldSkip(pointerWork, bookingDate)) {
      switch (
          durationStrikings(currentTime, currentTime, pointerWork, endWork)) {
        case 'BEFORE': // current is later
          logger.d("Alg duration status - BEFORE");
          continue;
        case 'AFTER': // current is passed
          logger.d("Alg duration status - AFTER");
          break;
        case 'STRIKE': // current in this section
          logger.d("Alg duration status - STRIKE");
          break;
      }
      pointerWork = currentTime;
    }
    // generate optional treatment starting at 'pointerWork'
    Map<String, Map<String, dynamic>> timeSegments =
        generateTimeSegmentsMap(booking, pointerWork);
    // pass over the current time stamp
    while (!((timeSegments.values.last['start'] as DateTime)
            .add(timeSegments.values.last['duration']))
        .isAfter(endWork)) {
      i++;
      if (i > 500) {
        logger.e('Infinity loop in times algorited - stopping');
        break;
      }

      // get time to jump to next optional time
      int minutesToJump = minutesToJumpOverForbbiden(
          forbiddenTimesPointers, timeSegments, forbbidenTimes);
      // caculate the dafault jump time
      int jump = getJump(timeSegments.values.first['start'] as DateTime,
          forbbidenTimes, forbiddenTimesPointers, worker.shortBookingTime);
      // if this set to 0 -> no need to jump - allowed time
      bool allwed_time = minutesToJump == 0;

      // add the time and save place to short bookings
      if (allwed_time) {
        logger.d("generate new val -> $i");
        // adding only the first time ( start of the treatment )
        yield timeSegments.values.first['start'] as DateTime;
        /* for worker when edit customer booking
        we don't need to optimaize the times by the shorter turn 
        cause worker already can set turn every 5 minutes in task
        */
        if (workerSheet) {
          //pointerWork = pointerWork.add(Duration(minutes: 5));
          addMinutesToAllSegments(timeSegments, 5);
        } else {
          // pointerWork =
          //   pointerWork.add(Duration(minutes: worker.shortBookingTime));

          addMinutesToAllSegments(timeSegments, jump);
        }
      } else {
        // finish pass all over the firbbiden times
        // (pointer of the first segment endTime is out if the list)
        if (forbbidenTimes.length - 1 < forbiddenTimesPointers.first + 1) {
          if (workerSheet) {
            //pointerWork = pointerWork.add(Duration(minutes: 5));
            addMinutesToAllSegments(timeSegments, 5);
          } else {
            // pointerWork =
            //     pointerWork.add(Duration(minutes: worker.shortBookingTime));
            addMinutesToAllSegments(timeSegments, jump);
          }
        }
        // jump to the end of the current forbbiden time -> save time complexity
        else {
          // if strike adding the best time (longest)
          addMinutesToAllSegments(timeSegments, minutesToJump);
        }
      }
    }
  }
  //return hours;
}

int getJump(DateTime currentTime, List<DateTime> forbbidenTimes,
    List<int> indexesInForbidden, int dafaultAdding) {
  /* if the default jump is passing over next forbbiden - 
  comming back to end forbiden to save holes in scedule */
  DateTime afterAdding = currentTime.add(Duration(minutes: dafaultAdding));
  if (indexesInForbidden.length <= 0 ||
      (indexesInForbidden[0] + 1 >= forbbidenTimes.length))
    return dafaultAdding;

  DateTime nextForbidden = forbbidenTimes[indexesInForbidden[0]];
  DateTime endForbidden = forbbidenTimes[indexesInForbidden[0] + 1];
  if (nextForbidden.isAfter(currentTime) &&
      nextForbidden.isBefore(afterAdding)) {
    return endForbidden.difference(currentTime).inMinutes;
  }
  return dafaultAdding;
}

bool isOptionalTimeForBooking(
  WorkerModel? worker,
  Booking booking,
  DateTime timeToOrder, {
  List<DateTime>? defaultWork,
  List<DateTime>? defaultVacations,
  List<DateTime>? defaultBreaks,
  List<DateTime>? defaultTakenHoures,
  List<DateTime>? defaultForbbidenTimes,
}) {
  if (worker == null) return false;
  // free day -> holiday
  if (worker.closeScheduleOnHolidays &&
      isHoliday(worker, booking.bookingDate)) {
    logger.d("Holiday is free day for this worker -> don't generate times");
    //return hours;
    return false;
  }

  // vars to make code cleaner
  String bookingDate = DateFormat('dd-MM-yyyy').format(booking.bookingDate);

  // relevant times to calculate
  String weekDay = DateFormat('EEEE').format(booking.bookingDate).toLowerCase();
  List<DateTime> work =
      defaultWork ?? convertStringToTime(worker.workTime[weekDay]);
  List<DateTime> vacations =
      defaultVacations ?? convertStringToTime(worker.vacations[bookingDate]);
  List<DateTime> breaks =
      defaultBreaks ?? getTodayListOfBreaks(bookingDate, worker.breaks);
  List<DateTime> takenHoures = defaultTakenHoures ??
      alreadyTakenHoures(worker, bookingDate,
          isUpdate: false, oldBooking: null);
  List<DateTime> forbbidenTimes =
      defaultForbbidenTimes ?? (vacations + takenHoures + breaks);

  // all day free
  if (worker.vacations[bookingDate] != null && vacations.length == 0) {
    logger.d("Free day don't generate times");
    //return hours;
    return false;
  }
  // sorting the lists
  if (defaultWork != null) {
    work.sort();
  }
  if (defaultForbbidenTimes != null) {
    forbbidenTimes.sort();
  }
  // get-rid of erlier times - not necessary
  forbbidenTimes = getOnlyEqualOrAfter(forbbidenTimes, timeToOrder);
  // fill this list with 0 those will be the pointers on each time segments
  List<int> forbiddenTimesPointers =
      List.generate(booking.treatment.times.keys.length, (index) => 0);
  // pass over the work times
  for (var j = 0; j < work.length; j += 2) {
    DateTime pointerWork = work[j];
    DateTime endWork = work[j + 1];
    // if we passed the time - failed to set booking in this time
    if (pointerWork.isAfter(timeToOrder)) {
      break;
    }
    // jumping to the relevant time section
    if (!endWork.isAfter(timeToOrder)) {
      continue;
    }
    // the "timeToOrder" have to be in this time section - jumping to it
    pointerWork = timeToOrder;
    // validate the treatment isn't keep after the work session is done
    if (pointerWork
        .add(Duration(minutes: booking.treatment.totalMinutes))
        .isAfter(endWork)) {
      return false;
    }
    // now in the relevant time section setting the start time
    // generate given booking starting at 'pointerWork'
    Map<String, Map<String, dynamic>> timeSegments =
        generateTimeSegmentsMap(booking, pointerWork);

    // getting time to jump if one or more time segments triking with forbbiden
    int minutesToJump = minutesToJumpOverForbbiden(
        forbiddenTimesPointers, timeSegments, forbbidenTimes);
    bool allwed_time = minutesToJump == 0;
    return allwed_time;
  }
  return false;
}

List<DateTime> getOnlyEqualOrAfter(List<DateTime> times, DateTime startTime) {
  /* get data time list like so - [start,end,start,end]
  return data time list only peers that the end is after the "startTime" */
  List<DateTime> filteredList = [];
  for (int i = 0; i < times.length; i += 2) {
    if (!times[i + 1].isBefore(startTime)) {
      filteredList.add(times[i]);
      filteredList.add(times[i + 1]);
    }
  }
  return filteredList;
}

List<DateTime> getBookingTimes(Booking booking) {
  List<DateTime> times = [];
  booking.treatment.times.forEach((timeNumber, timeData) {
    timeData['duration'];
  });
  return times;
}

List<DateTime> alreadyTakenHoures(WorkerModel worker, String bookingDate,
    {bool isUpdate = false, Booking? oldBooking = null}) {
  List<DateTime> taken = [];
  if (worker.bookingsTime.keys.contains(bookingDate)) {
    worker.bookingsTime[bookingDate]!.keys.map((key) {
      DateTime start = DateFormat('HH:mm').parse(key);
      taken.add(start);
      taken.add(start
          .add(Duration(minutes: worker.bookingsTime[bookingDate]![key]!)));
    }).toList();
  }
  // update -> allowed you to see hours that your turn block
  if (isUpdate) {
    // to make it in 1970 - date
    DateTime startTime = DateFormat('HH:mm')
        .parse(DateFormat('HH:mm').format(oldBooking!.bookingDate));
    // pass over the timeSegments and remove all the segments
    oldBooking.treatment.times.forEach((timeIndex, timeData) {
      DateTime endTime =
          startTime.add(Duration(minutes: timeData['duration']!));
      taken.remove(startTime);
      taken.remove(endTime);
      startTime = endTime.add(Duration(minutes: timeData['break']!));
    });
  }
  return taken;
}

List<DateTime> convertStringToTime(List<String>? strTimes) {
  if (strTimes == null) return [];
  List<DateTime> times = [];
  strTimes.forEach((element) {
    times.add(DateFormat('HH:mm').parse(element));
  });
  return times;
}

List<DateTime> convertStringToDateTime(List<String>? strTimes) {
  if (strTimes == null) return [];
  List<DateTime> times = [];
  strTimes.forEach((element) {
    times.add(DateFormat('dd-MM-yyyy').parse(element));
  });
  return times;
}

List<DateTime> getTodayListOfBreaks(
    String day, Map<String, BreakModel> breaks) {
  List<DateTime> todayBreaks = [];
  breaks.forEach((key, value) {
    if (value.day == day) {
      DateTime start = DateFormat('HH:mm').parse(value.start);
      todayBreaks.add(start);
      todayBreaks.add(start.add(value.duration));
    }
  });
  return todayBreaks;
}

DateTime getTimeDevideByFive(DateTime time, {bool inCheckFormat = false}) {
  /*
  get time and return the same time rount to the up 5 minutes
   */
  int minutes = time.minute;
  int tens = (minutes / 10).floor(); // only the times witout decimal point
  int ones = minutes % 10; // the rest
  int amountOfFives = (ones / 5).ceil();
  if (inCheckFormat) {
    return DateTime(1970, 1, 1, time.hour, (tens * 10) + (amountOfFives * 5));
  }
  return DateTime(time.year, time.month, time.day, time.hour,
      (tens * 10) + (amountOfFives * 5));
}

DateTime getValidDataTimeToCheck(DateTime time) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String text = DateFormat('HH:mm').format(time);
  int minutes = int.parse(twoDigits(int.parse(text[3] + text[4])));
  int hours = int.parse(twoDigits(int.parse(text[0] + text[1])));
  return DateTime(1970, 1, 1, hours, minutes);
}

Booking getFakeBookingToCheck(
    String treatmentName, Treatment treatment, DateTime date) {
  return new Booking()
    ..bookingDate = date
    ..treatment.name = treatmentName
    ..treatment.totalMinutes = treatment.totalMinutes
    ..treatment.price = treatment.price
    ..treatment.times = {...treatment.times};
}

Booking getFakeBookingFromBreak(BreakModel breakModel) {
  return new Booking()
    ..bookingDate = DateFormat('dd-MM-yyyy').parse(breakModel.day)
    ..treatment.totalMinutes = breakModel.duration.inMinutes
    ..treatment.times = {
      '0': {'break': 0, 'duration': breakModel.duration.inMinutes, 'title': ''}
    };
}

Booking getFakeBookingFromTime(String day, String start, String end) {
  DateTime startEvent = DateFormat('HH:mm').parse(start);
  DateTime endEvent = DateFormat('HH:mm').parse(end);
  int totalMinutes = endEvent.difference(startEvent).inMinutes;
  // key - day dd-MM-yyy, val - [HH:mm,HH:mm ,HH:mm,HH:mm..]
  return new Booking()
    ..bookingDate = DateFormat('dd-MM-yyyy').parse(day)
    ..treatment.totalMinutes = totalMinutes
    ..treatment.times = {
      '0': {'break': 0, 'duration': totalMinutes, 'title': ''}
    };
}

Map<DateTime, BreakModel> getTodayBreaks(
    String day, Map<String, BreakModel> breaks) {
  Map<DateTime, BreakModel> todayBreaks = {};
  breaks.forEach((key, value) {
    if (value.day == day) {
      /*detemind when every event happen - used when worker wants to add a break*/
      ScheduleList.eventsTimes.add(DateFormat('HH:mm').parse(value.start));
      todayBreaks[DateFormat('HH:mm').parse(value.start)] = value;
    }
  });
  return todayBreaks;
}

String addDurationFromDateString(String date, Duration duration) {
  final dateObj = DateFormat("HH:mm").parse(date).add(duration);
  return DateFormat("HH:mm").format(dateObj);
}

DateTime setTo1970(DateTime dateTime) {
  return DateFormat('HH:mm').parse(DateFormat('HH:mm').format(dateTime));
}

DateTime setToMidNight(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy')
      .parse(DateFormat('dd-MM-yyyy').format(dateTime));
}

DateTime setToStartOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, 1);
}

bool isHoliday(WorkerModel worker, DateTime date) {
  bool isHoliday = false;
  worker.religions.forEach((religion) {
    String dateString = DateFormat('dd-MM-yyyy').format(date);
    switch (religion) {
      case Religion.christian:
        dateString = dateString.substring(0, dateString.length - 4) + "0000";
        isHoliday =
            isHoliday || holidays[Religion.christian]!.containsKey(dateString);
        return;
      default:
        isHoliday = isHoliday || holidays[religion]!.containsKey(dateString);
        return;
    }
  });
  return isHoliday;
}

List<String> getHolidayName(WorkerModel worker, DateTime date) {
  List<String> holidaysString = [];
  worker.religions.forEach((religion) {
    String dateString = DateFormat('dd-MM-yyyy').format(date);
    switch (religion) {
      case Religion.christian:
        dateString = dateString.substring(0, dateString.length - 4) + "0000";
        if (holidays[religion]![dateString] != null) {
          holidaysString.add(holidays[religion]![dateString]!);
        }
        return;
      default:
        if (holidays[religion]![dateString] != null) {
          holidaysString.add(holidays[religion]![dateString]!);
        }
        return;
    }
  });
  return holidaysString;
}
