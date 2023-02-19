import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_tor_web/app_const/worker_scedule.dart';
import 'package:simple_tor_web/app_statics.dart/settings_data.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/times_utlis.dart';

import '../app_const/application_general.dart';
import '../app_const/db.dart';
import '../app_const/purchases.dart';
import '../models/booking_model.dart';
import '../models/break_model.dart';
import '../models/notification_topic.dart';
import '../models/worker_model.dart';
import '../providers/helpers/db_pathes_helper.dart';
import '../services/clients/firebase_real_time_client.dart';
import '../services/clients/firestore_client.dart';
import '../services/clients/server_notifications_client.dart';
import '../services/errors_service/app_errors.dart';
import '../services/errors_service/messages.dart';
import '../services/errors_service/worker.dart';
import 'general_data.dart';

class WorkerData {
  static WorkerModel worker = WorkerModel(); // hold the current worker
  static Stream<DocumentSnapshot<Map<String, dynamic>>>? workerDocListener;
  static DateTime focusedDay = DateTime.now(); // the currend day in the diary
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      workersBookingsObjectsListener;
  static Map<String, Map<String, Booking>> monthlyBookingsData = {};
  static bool alreadyLoadData = false;
  static Stream<DatabaseEvent>? waitingListListener;
  static bool hasMonthlyBookingsData() {
    return alreadyLoadData;
  }

  static Stream<DatabaseEvent> listenToWaitingList(String date) {
    /* date format - dd-MM-yy */
    //stop previus listener
    stopWaitingListListener();
    // save the listener
    waitingListListener = FirebaseRealTimeClient().getListenerToChild(
        pathToChild:
            '${DbPathesHelper().getAllWaitingListsChildPath(worker)}/$date');
    return waitingListListener!;
  }

  static void stopWaitingListListener() {
    if (waitingListListener == null) {
      return;
    }
    waitingListListener;
  }

  static Future<bool> loadMonthlyBookingsData() async {
    if (alreadyLoadData) return true;
    // await Future.delayed(Duration(seconds: 2));
    // return true;
    DateTime startMonth = setToStartOfMonth(DateTime.now());
    DateTime endOfMonth = setToStartOfMonth(startMonth.add(Duration(days: 33)));
    final workersPath =
        "$buisnessCollection/${SettingsData.appCollection}/$workersCollection";
    while (startMonth.isBefore(endOfMonth)) {
      String dayString = DateFormat('dd-MM-yyyy').format(startMonth);
      Map<String, dynamic>? dayBookings = (await FirestoreClient().getDoc(
              path:
                  "$workersPath/${worker.phone}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
              docId: dayString))
          .data();
      if (dayBookings != null) {
        monthlyBookingsData[dayString] = {};
        dayBookings.forEach((key, value) {
          monthlyBookingsData[dayString]![key] = Booking.fromJson(value);
        });
      }
      // jumping to the next day
      startMonth = startMonth.add(Duration(days: 1));
    }

    alreadyLoadData = true;
    return true;
  }

  static Future<void> setWeekend(
      List<dynamic> newWeekend, BuildContext context) async {
    if (newWeekend == worker.weekendDays) return;
    final newWeekendCasted = (newWeekend).map((item) => item as int).toList();
    worker.weekendDays = newWeekendCasted;
    UiManager.insertUpdate(Providers.worker);
    UiManager.updateUi(context: context);

    await FirestoreClient().updateFieldInsideDocAsMap(
        path:
            "$buisnessCollection/${SettingsData.appCollection}/$workersCollection",
        docId: worker.phone,
        fieldName: "weekendDays",
        value: newWeekendCasted);
  }

  static Future<bool> setReligions(
      List<dynamic> newReligions, BuildContext context) async {
    if (newReligions == worker.religions) {
      AppErrors.error = Errors.unknown;
      return false;
    }
    final newReligionsCasted =
        (newReligions).map((item) => item as Religion).toList();

    return await FirestoreClient()
        .setHolidays(
            worker: worker,
            religions: newReligionsCasted,
            changeCloseScheduleOnHolidays: false)
        .then(
      (value) {
        if (value) {
          worker.religions = newReligionsCasted;
          UiManager.insertUpdate(Providers.worker);
        }
        return value;
      },
    );
  }

  static Future<bool> setCloseScheduleOnHolidays(
      bool value, BuildContext context,
      {bool onLoading = true}) async {
    if (value == worker.closeScheduleOnHolidays) {
      AppErrors.error = Errors.unknown;
      return false;
    }
    if (!onLoading) {
      worker.closeScheduleOnHolidays = value;
      UiManager.insertUpdate(Providers.worker);
      UiManager.updateUi(context: context);
    }
    if (!value) {
      return await FirestoreClient().updateFieldInsideDocAsMap(
          path:
              "$buisnessCollection/${SettingsData.appCollection}/$workersCollection",
          docId: worker.phone,
          fieldName: "closeScheduleOnHolidays",
          value: value);
    } else {
      return await FirestoreClient()
          .setHolidays(
              worker: worker,
              religions: worker.religions,
              changeCloseScheduleOnHolidays: true)
          .then((value) {
        if (value) {
          worker.closeScheduleOnHolidays = value;
          UiManager.insertUpdate(Providers.worker);
        }
        return value;
      });
    }
  }

  //----------------------- breaks -----------------------------

  static Future<bool> setBreakNote(
      {required BreakModel breakModel, required String noteString}) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.setBreakNote]);

    if (breakModel.note == noteString) return true;
    if (!worker.breaks.containsKey(breakModel.id)) return false;
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: worker.phone,
            fieldName: "breaks.${breakModel.id}.note",
            value: noteString)
        .then((value) {
      if (value) {
        worker.breaks[breakModel.id]!.note = noteString;
        UiManager.insertUpdate(Providers.worker);
      }
      return value;
    });
  }

  // ----------------------  Bookings  Objects ------------------

  static Future<bool> setBookingNote(
      {required Booking booking, required String noteString}) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.setBookingNote]);

    if (booking.note == noteString) return true;
    final dateKey = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    return await FirestoreClient().updateFieldInsideDocAsMap(
        path:
            "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection/${booking.workerId}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
        docId: dateKey,
        fieldName: "${booking.bookingId}.note",
        value: noteString);
  }

  static Future<bool> addBreak(BreakModel breakModel) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.addBreak]);
    if (worker.breaks.containsKey(breakModel.id)) return false;
    return await FirestoreClient()
        .addBreak(breakModel: breakModel, workerPhone: worker.phone)
        .then((value) {
      if (value) {
        worker.breaks[breakModel.id] = breakModel;
        UiManager.insertUpdate(Providers.worker);
      }
      return value;
    });
  }

  static Future<bool> removeBreak(BreakModel breakModel) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.removeBreak]);
    String breakKey = "${breakModel.day}T${breakModel.start}";
    if (!worker.breaks.containsKey(breakKey)) return false;
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: worker.phone,
      fieldName: "breaks.$breakKey",
    )
        .then((value) {
      if (value) {
        worker.breaks.remove(breakKey);
        UiManager.insertUpdate(Providers.worker);
      }
      return value;
    });
  }

  static void updateWorkerBookingsObjects(
      DocumentSnapshot<Map<String, dynamic>> bookingObjectsJson) {
    /* update the bookingsObjects of the worker object 
      from the bookingsObjectsJson */
    final dateString = DateFormat('dd-MM-yyyy').format(focusedDay);

    worker.setBookingsObjects(bookingObjectsJson.data() ?? {}, dateString);
    logger.d("Get new worker bookingsObjects --> $dateString");
    UiManager.insertUpdate(Providers.worker);
    UiManager.updateUi(context: GeneralData.generalContext!);
  }

  static void startListener({required DateTime date}) {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.makeListener]);
    /*create worker listener for the bookingsObject ONLY worker
      has that kind of listener and ONLY for himself*/
    final dateString = DateFormat('dd-MM-yyyy').format(date);

    if (setToMidNight(date).isBefore(setToMidNight(DateTime.now())) &&
        worker.bookingObjects.containsKey(dateString)) {
      /*passed bookings cant be changed - not need to open a listener
        every time  the workerModel cache the bookings that we already
        get from db for saving reads */
      logger.d(
          "Already has in cache this passed day we not need to load it again");
      return;
    }
    try {
      final workersPath =
          "$buisnessCollection/${SettingsData.appCollection}/$workersCollection";
      workerDocListener = FirestoreClient().docListener(
          path:
              "$workersPath/${worker.phone}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
          docId: dateString);
      workersBookingsObjectsListener =
          workerDocListener!.listen((bookingObjectsJson) {
        updateWorkerBookingsObjects(bookingObjectsJson);
      });

      logger.d(
          "Workers bookingObjects Listening have successfully create --> $dateString");
    } catch (e) {
      logger.d(
          "Error while create the Workers bookingObjects Listening -->$dateString");
    }
  }

  static Future<void> cancelListening() async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.cancelListening]);
    try {
      await workersBookingsObjectsListener!.cancel();
      logger.d("Workers bookingObjects have canceled");
    } catch (e) {
      logger.d("Error while cancel the Workers bookingObjects");
    }
  }

  static void setFocusedDate(DateTime date) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.setFocusedDate]);
    if (focusedDay == date) return;
    focusedDay = date;

    UiManager.insertUpdate(Providers.worker);
    /*cancel exist listening and create new one for the new day*/
    await cancelListening();
    startListener(date: date);
    worker.initDetails();
  }

  static Future<void> updateOnHoldMinutesIfNeeded() async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.updateOnHoldMinutesIfNeeded]);
    if (SettingsData.businessSubtype == SubType.basic &&
        worker.onHoldMinutes > 0) {
      await FirestoreClient()
          .updateFieldInsideDocAsMap(
              path:
                  "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
              docId: worker.phone,
              fieldName: "onHoldMinutes",
              value: 0)
          .then((value) {
        if (value) {
          worker.onHoldMinutes = 0;
          logger.d("Update worker onHoldMinutes successfully");
        }
        return value;
      });
    }
  }

  static Future<bool> deleteAllBookingObjectsOfTheDay(DateTime date) async {
    return await FirestoreClient()
        .deleteDoc(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection/${worker.phone}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
            docId: DateFormat('dd-MM-yyyy').format(date))
        .then((value) {
      if (value) {
        if (worker.bookingObjects
            .containsKey(DateFormat('dd-MM-yyyy').format(date))) {
          worker.bookingObjects[DateFormat('dd-MM-yyyy').format(date)] = {};
          UiManager.insertUpdate(Providers.worker);
        }
      }
      return value;
    });
  }

  static Future<bool> saveWorkTime() {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.saveWorkTime]);
    return FirestoreClient()
        .updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: worker.phone,
      fieldName: "workTime",
      value: worker.workTime,
    )
        .then((resp) {
      UiManager.insertUpdate(Providers.worker);
      return resp;
    });
  }

  static Future<void> updateShowSceduleColors(
      bool val, BuildContext context) async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.addTimeToVacations]);
    worker.showSceduleColors = val;
    UiManager.insertUpdate(Providers.worker);
    UiManager.updateUi(context: context);
    await FirestoreClient().updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: worker.phone,
      fieldName: "showSceduleColors",
      value: val,
    );
  }

  static Future<bool> saveVacations(
      {required Map<String, List<String>> vacations,
      required Set<String> days}) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.saveVacations]);
    Function deepEq = const DeepCollectionEquality().equals;
    if (deepEq(vacations, worker.vacations)) {
      logger.i('Nothing changes return true - no access to db');

      return true;
    }
    ;
    // get the business id
    String businessId = SettingsData.appCollection;
    // notify the waiting list for changing days
    days.forEach((date) {
      logger.d("Notify new bookings in --> $date");
      ServerNotificationsClient().notifyCanceldBooking(
          topic: NotificationTopic(
                  businessId: businessId,
                  workerId: worker.phone,
                  date: date,
                  workerName: worker.name)
              .toTopicStr());
    });
    return await FirestoreClient()
        .updateVacations(workerPhone: worker.phone, vacations: vacations)
        .then((value) {
      if (value) {
        worker.vacations = {...vacations};
        UiManager.insertUpdate(Providers.worker);
      }
      return value;
    });
  }

  static Future<void> changeDaysToAllowBookings(
      int days, BuildContext context) async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.changeDaysToAllowBookings]);
    worker.daysToAllowBookings = days;
    UiManager.insertUpdate(Providers.worker);
    UiManager.updateUi(context: context);
    await FirestoreClient().updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: worker.phone,
      fieldName: "daysToAllowBookings",
      value: days,
    );
  }
}
