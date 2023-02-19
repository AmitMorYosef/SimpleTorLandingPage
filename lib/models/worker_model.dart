import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:simple_tor_web/models/booking_model.dart';
import 'package:simple_tor_web/models/break_model.dart';
import 'package:simple_tor_web/models/price_model.dart';
import 'package:simple_tor_web/models/treatment_model.dart';
import 'package:simple_tor_web/utlis/times_utlis.dart';

import '../app_const/gender.dart';
import '../app_const/worker_scedule.dart';
import '../app_statics.dart/worker_data.dart';

class WorkerModel {
  int daysToAllowBookings = 7;
  String name = "";
  String phone = "";
  String profileImg = "";
  String currentFcm = "";
  String ewallet = "";
  bool notifyOnWaitingListEvents = true;
  String payment_currency = "";
  List<Religion> religions = [];
  bool closeScheduleOnHolidays = false;
  List<int> weekendDays = [DateTime.friday, DateTime.saturday];
  int onHoldMinutes = 0;
  int shortBookingTime = 999;
  bool saveData = true;
  Map<String, double> workerData = {};
  String lastDeleteBookingsDataDay = "";
  bool notifyWhenGettingBooking = false;
  bool allowNotLoggedInBookings = false;
  Map<String, int> storylikesAmount = {}; // {image_id: 3} hold real time likes
  Timestamp lastCleanDate = Timestamp.fromDate(DateTime.now());
  Gender gender = Gender.anonymous;
  Map<String, String> storyImages = {};
  Map<String, List<String>> workTime = {
    "sunday": [],
    "monday": [],
    "tuesday": [],
    "wednesday": [],
    "thursday": [],
    "friday": [],
    "saturday": [],
  };
  Map<String, List<String>> vacations = {};
  Map<String, BreakModel> breaks = {};
  Map<String, Treatment> treatments = {};
  Map<String, Map<String, Booking>> bookingObjects = {};
  Map<String, Map<String, int>> bookingsTime = {}; // hold the worker's bookings
  bool showSceduleColors = true;
  int generalBookingsCount = 0, passedBookingsCount = 0;

  Map<String, Price?> passedMoneyAmount = {}, generalMoneyAmount = {};

  WorkerModel.fromWorkerDocJson(
    Map<String, dynamic> workerJson,
  ) {
    /*This function will create new worker from that json dont use it
     if you want to update the worker it will not consider the worker 
     publicData doc r*/
    daysToAllowBookings = workerJson["daysToAllowBookings"];
    if (workerJson["religions"] != null) {
      religions = [];
      (workerJson["religions"] as List<dynamic>).forEach((religion) {
        religions.add(religionFromStr[religion]!);
      });
    }
    closeScheduleOnHolidays = workerJson["closeScheduleOnHolidays"] ?? false;
    if (workerJson["weekendDays"] != null) {
      weekendDays = [];
      (workerJson["weekendDays"] as List<dynamic>).forEach((dayOfWeek) {
        weekendDays.add(dayOfWeek);
      });
    }
    profileImg = workerJson['profileImg'];
    lastCleanDate = workerJson['lastCleanDate'];
    gender = genderFromStr[workerJson['gender']]!;
    name = workerJson['name'];
    notifyOnWaitingListEvents = workerJson["notifyOnWaitingListEvents"] ?? true;
    saveData = workerJson['saveData'] ?? true;
    ewallet = workerJson["ewallet"] ?? "";
    lastDeleteBookingsDataDay = workerJson["lastDeleteBookingsDataDay"] ?? "";
    payment_currency = workerJson["payment_currency"] ?? "";
    //durationToCleanExpired = Duration(days: workerJson['daysToCleanExpired']);
    phone = workerJson['phone'];
    currentFcm = workerJson['currentFcm'] ?? "";
    notifyWhenGettingBooking = workerJson["notifyWhenGettingBooking"] ?? false;
    allowNotLoggedInBookings = workerJson["allowNotLoggedInBookings"] ?? false;
    showSceduleColors = workerJson["showSceduleColors"] ?? true;
    workerJson['treatments'].forEach((name, treatmentJson) {
      treatments[name] = Treatment.fromJson(treatmentJson, name);
      if (treatments[name]!.totalMinutes < shortBookingTime) {
        shortBookingTime = max(treatments[name]!.times['0']!['duration'], 5);
      }
    });
    onHoldMinutes = workerJson['onHoldMinutes'];
    workerJson["workTime"].forEach((key, val) {
      workTime[key] = val.map<String>((item) => item as String).toList();
    });

    workerJson["vacations"].forEach((stringDate, val) {
      //get rid of expired vacation
      if (!DateFormat('dd-MM-yyyy')
          .parse(stringDate)
          .isBefore(setToMidNight(DateTime.now())))
        vacations[stringDate] =
            val.map<String>((item) => item as String).toList();
    });
    if (workerJson["breaks"] != null) {
      workerJson["breaks"].forEach((key, breakJson) {
        //get rid of expired breaks
        if (!DateFormat('dd-MM-yyyy')
            .parse(key.split('T')[0])
            .isBefore(setToMidNight(DateTime.now()))) {
          breaks[key] = BreakModel.fromJson(breakJson, key);
        }
      });
    }
    if (workerJson["storyImages"] != null) {
      workerJson["storyImages"].forEach((imageId, image) {
        storyImages[imageId] = image;
      });
    }
  }

  void setFromWorkerDoc(
    Map<String, dynamic> workerJson,
  ) {
    daysToAllowBookings = workerJson["daysToAllowBookings"];
    profileImg = workerJson['profileImg'];
    lastCleanDate = workerJson['lastCleanDate'];
    if (workerJson["religions"] != null) {
      religions = [];
      (workerJson["religions"] as List<dynamic>).forEach((religion) {
        religions.add(religionFromStr[religion]!);
      });
    }
    notifyOnWaitingListEvents = workerJson["notifyOnWaitingListEvents"] ?? true;
    closeScheduleOnHolidays = workerJson["closeScheduleOnHolidays"] ?? false;
    if (workerJson["weekendDays"] != null) {
      weekendDays = [];
      (workerJson["weekendDays"] as List<dynamic>).forEach((dayOfWeek) {
        weekendDays.add(dayOfWeek);
      });
    }
    gender = genderFromStr[workerJson['gender']]!;
    name = workerJson['name'];
    saveData = workerJson['saveData'] ?? true;
    ewallet = workerJson["ewallet"] ?? "";
    lastDeleteBookingsDataDay = workerJson["lastDeleteBookingsDataDay"] ?? "";
    payment_currency = workerJson["payment_currency"] ?? "";
    phone = workerJson['phone'];
    currentFcm = workerJson['currentFcm'] ?? "";
    notifyWhenGettingBooking = workerJson["notifyWhenGettingBooking"] ?? false;
    allowNotLoggedInBookings = workerJson["allowNotLoggedInBookings"] ?? false;
    treatments = {};
    workerJson['treatments'].forEach((name, treatmentJson) {
      treatments[name] = Treatment.fromJson(treatmentJson, name);
      if (treatments[name]!.totalMinutes < shortBookingTime) {
        shortBookingTime = max(treatments[name]!.times['0']!['duration'], 5);
      }
    });
    onHoldMinutes = workerJson['onHoldMinutes'];
    workTime = {};
    workerJson["workTime"].forEach((key, val) {
      workTime[key] = val.map<String>((item) => item as String).toList();
    });
    vacations = {};
    workerJson["vacations"].forEach((stringDate, val) {
      //get rid of expired vacation
      if (!DateFormat('dd-MM-yyyy')
          .parse(stringDate)
          .isBefore(setToMidNight(DateTime.now())))
        vacations[stringDate] =
            val.map<String>((item) => item as String).toList();
    });
    breaks = {};
    if (workerJson["breaks"] != null) {
      workerJson["breaks"].forEach((key, breakJson) {
        //get rid of expired breaks
        breaks[key] = BreakModel.fromJson(breakJson, key);
      });
    }
    storyImages = {};
    if (workerJson["storyImages"] != null) {
      workerJson["storyImages"].forEach((imageId, image) {
        storyImages[imageId] = image;
      });
    }
  }

  void setWorkerPublicData(Map<String, dynamic> dataJson) {
    bookingsTime = {};
    if (dataJson["bookingsTimes"] != null) {
      dataJson["bookingsTimes"].forEach((dateString, times) {
        if (!DateFormat('dd-MM-yyyy')
            .parse(dateString)
            .isBefore(DateTime.now().subtract(Duration(days: 1)))) {
          bookingsTime[dateString] = {};
          (times as Map).forEach((time, duration) {
            // set shorter data just to know the bookings time & duration
            DateTime lastTime = DateFormat('HH:mm').parse(time);
            bookingsTime[dateString]![DateFormat('HH:mm').format(lastTime)] =
                duration as int;
          });
        }
      });
    }
  }

  Map<String, dynamic> toWorkerPublicDataJson() {
    final Map<String, dynamic> data = {};
    data["bookingsTimes"] = {};
    bookingsTime.forEach((date, map) {
      data["bookingsTimes"][date] = {};
      map.forEach((time, duration) {
        data["bookingsTimes"][date]![time] = duration;
      });
    });

    return data;
  }

  void initDetails() {
    generalBookingsCount = 0;
    passedBookingsCount = 0;
    passedMoneyAmount = {};
    generalMoneyAmount = {};
  }

  void setBookingsObjects(
      Map<String, dynamic> bookingsObjectsJson, String dateString) {
    /*this func only for the worker himself - ONLY he listen to 
      the bookingsObjects collection*/
    bookingObjects[dateString] = {};
    initDetails();
    WorkerData.monthlyBookingsData[dateString] =
        bookingObjects[dateString] ?? {}; // update the cache also
    bookingsTime[dateString] = {};
    bookingsObjectsJson.forEach((bookingId, bookingJson) {
      final bookingObj = Booking.fromJson(bookingJson);
      bookingObjects[dateString]![bookingObj.bookingId] = bookingObj;
      DateTime lastTime = bookingObj.bookingDate;
      bookingObj.treatment.times.forEach((timeIndex, timeData) {
        /*also fill the bookings times for the worker  - the worker
         doesnt need to listen to his own bookings times it can be 
         generate from the bookings objects */
        /*Sparate the booking to passed and not passed*/
        bookingsTime[dateString]![DateFormat('HH:mm').format(lastTime)] =
            timeData['duration'] as int;
        // jumping to the end of the segment
        lastTime = lastTime.add(Duration(minutes: timeData['duration'] as int));
        // addint the break after segment
        lastTime = lastTime.add(Duration(minutes: timeData['break'] as int));
      });

      final currencyCode = bookingObj.treatment.price!.currency!.code;
      /*Get the details about the orders and their prices*/
      if (bookingObj.bookingDate
          .add(Duration(minutes: bookingObj.treatment.totalMinutes))
          .isBefore(DateTime.now())) {
        passedBookingsCount += 1;

        /*update the passedMoneyAmount with the current amount */
        if (passedMoneyAmount.containsKey(currencyCode)) {
          passedMoneyAmount[currencyCode]!.add(bookingObj.treatment.price!);
        } else {
          passedMoneyAmount[currencyCode] = Price(
              amount: bookingObj.treatment.price!.amount.toString(),
              currency: bookingObj.treatment.price!.currency!);
        }
      }
      /*passedMoneyAmount and generalMoneyAmount need to have 
          the same keys - put price 0 in case there isnt a code 
          like this*/
      if (!passedMoneyAmount.containsKey(currencyCode)) {
        passedMoneyAmount[currencyCode] =
            Price(amount: "0", currency: bookingObj.treatment.price!.currency!);
      }

      generalBookingsCount += 1;
      /*update the generalMoneyAmount with the current amount */
      if (generalMoneyAmount.containsKey(currencyCode)) {
        generalMoneyAmount[currencyCode]!.add(bookingObj.treatment.price!);
      } else {
        generalMoneyAmount[currencyCode] = Price(
            amount: bookingObj.treatment.price!.amount.toString(),
            currency: bookingObj.treatment.price!.currency!);
      }
    });
  }

  WorkerModel.fromUserPublicData(Map<String, dynamic> json) {
    phone = json["phoneNumber"];
    name = json['name'];
    currentFcm = json["currentFcm"] ?? "";
    gender = genderFromStr[json['gender']]!;
    this.lastCleanDate = Timestamp.fromDate(DateTime.now());
  }

  WorkerModel({
    this.phone = '',
    this.profileImg = '',
    this.name = '',
    this.ewallet = '',
    this.payment_currency = '',
    this.daysToAllowBookings = 7,
    this.gender = Gender.anonymous,
    this.bookingObjects = const {},
    //this.durationToCleanExpired = const Duration(days: 30),
    this.currentFcm = "",
    this.lastDeleteBookingsDataDay = "",
    this.notifyWhenGettingBooking = false,
    this.allowNotLoggedInBookings = false,
    this.saveData = true,
    this.showSceduleColors = true,
    lastCleanDate,
    onHoldMinutes,
    treatments,
    workTime,
  });

  Map<String, dynamic> toWorkerDocJson() {
    final Map<String, dynamic> data = {};
    data['workTime'] = {};
    workTime.forEach((day, list) {
      data['workTime'][day] = list;
    });
    data['vacations'] = {};
    vacations.forEach((day, list) {
      data['vacations'][day] = list;
    });
    data['religions'] = [];
    religions.forEach((religion) {
      data['religions'].add(religionToStr[religion]);
    });
    data['closeScheduleOnHolidays'] = closeScheduleOnHolidays;
    data['notifyOnWaitingListEvents'] = notifyOnWaitingListEvents;
    data['weekendDays'] = weekendDays;
    data['gender'] = genderToStr[gender];
    data['onHoldMinutes'] = onHoldMinutes;
    data['lastCleanDate'] = lastCleanDate;
    data["ewallet"] = ewallet;
    data["saveData"] = saveData;
    data["lastDeleteBookingsDataDay"] = lastDeleteBookingsDataDay;
    data["payment_currency"] = payment_currency;
    data["currentFcm"] = currentFcm;
    data["notifyWhenGettingBooking"] = notifyWhenGettingBooking;
    data["allowNotLoggedInBookings"] = allowNotLoggedInBookings;
    data['daysToAllowBookings'] = daysToAllowBookings;
    data["breaks"] = {};
    breaks.forEach((key, breakModel) {
      data["breaks"][key] = breakModel.toJson();
    });
    data["treatments"] = {};
    treatments.forEach((name, treatment) {
      data["treatments"][name] = treatment.toJson();
    });
    data['profileImg'] = profileImg;
    data['name'] = name;
    data['phone'] = phone;
    data["showSceduleColors"] = showSceduleColors;
    data["storyImages"] = {};
    storyImages.forEach((imageId, image) {
      data["storyImages"][imageId] = image;
    });
    return data;
  }

  @override
  String toString() {
    return toWorkerDocJson().toString() + toWorkerPublicDataJson().toString();
  }
}
