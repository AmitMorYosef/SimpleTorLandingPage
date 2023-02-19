import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/services/errors_service/booking.dart';
import 'package:management_system_app/ui/ui_manager.dart';

import '../app_statics.dart/settings_data.dart';
import '../models/booking_model.dart';
import '../services/errors_service/app_errors.dart';

class BookingProvider extends ChangeNotifier {
  static bool sheetOpen =
      false; // for animation to know whether sheet is open or not
  static Booking booking = Booking(); // hold the current booking
  static String workerPhone = ''; // index of worker from the list in booking
  static bool isBreak = false;
  static String treatmentName =
      ''; // index of tretment from the list in booking
  static int timeIndex =
      -1; // index of the time from the List of hours in booking
  static Map<String, WorkerModel> workers = {};

  static void setup() {
    isBreak = false;
    workerPhone = '';
    treatmentName = '';
    booking = Booking();
  }

  static bool copyFromObject(Booking booking, BuildContext context) {
    AppErrors.addError(
        code: bookingCodeToInt[BookingErrorCodes.copyFromObject]);
    booking = Booking.fromBooking(booking);
    workerPhone = booking.workerId;
    treatmentName = booking.treatment.name;
    timeIndex = -1;
    //worker or treatment deleted
    return treatmentName != '';
  }

  static void setBreak(bool value) {
    isBreak = value;
    UiManager.insertUpdate(Providers.booking);
  }

  static void setDate(DateTime date) {
    AppErrors.addError(code: bookingCodeToInt[BookingErrorCodes.setDate]);
    booking.bookingDate = date;
    UiManager.insertUpdate(Providers.booking);
  }

  static void setWorkerPhone(
      {required String newWorkerPhone, bool needNotify = true}) async {
    AppErrors.addError(
        code: bookingCodeToInt[BookingErrorCodes.setWorkerPhone]);
    if (newWorkerPhone == workerPhone) return;
    //pause the previous listener
    await SettingsData.cancelWorkerListening();
    workerPhone = newWorkerPhone;
    //resumed the current worker listener
    SettingsData.startListening(workerPhone);
    if (needNotify) UiManager.insertUpdate(Providers.booking);
  }

  static void setTreatmentName(String newTreatmentName) {
    AppErrors.addError(
        code: bookingCodeToInt[BookingErrorCodes.setTreatmentName]);
    if (!workers.containsKey(workerPhone)) return;
    treatmentName = newTreatmentName;
    if (workers[workerPhone]!.treatments.containsKey(newTreatmentName)) {
      final treatment = workers[workerPhone]!.treatments[newTreatmentName];
      booking.treatment.name = newTreatmentName;
      booking.treatment.totalMinutes = treatment!.totalMinutes;
      booking.treatment.price = treatment.price;
      booking.treatment.times = {...treatment.times};
    }

    UiManager.insertUpdate(Providers.booking);
  }

  static void setTimeIndex(int index) {
    AppErrors.addError(code: bookingCodeToInt[BookingErrorCodes.setTimeIndex]);
    timeIndex = index;
    if (index == -1) {
      booking.bookingDate = DateTime(booking.bookingDate.year,
          booking.bookingDate.month, booking.bookingDate.day, 0, 0);
    }
    UiManager.insertUpdate(Providers.booking);
  }

  static void setSheetOpen(bool isOpen) => sheetOpen =
      isOpen; // determind if the user exsit from sheet -for animation

  static void updateWorkerData(WorkerModel workerObj) async {
    AppErrors.addError(
        code: bookingCodeToInt[BookingErrorCodes.updateWorkerData]);
    logger.d("Getting new data for the worker");

    workers[workerObj.phone] = workerObj;

    //if treatments had changed
    if (!workers[workerObj.phone]!.treatments.containsKey(treatmentName)) {
      setTreatmentName("");
      setDate(DateTime(0));
    }
    //if workers work time had changed
    final dateKey = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    final timeKey = DateFormat('HH:mm').format(booking.bookingDate);
    if (workers[workerObj.phone]!.bookingsTime.containsKey(dateKey))
      setDate(DateTime(0));
    if (workers[workerObj.phone]!.bookingsTime.containsKey(dateKey) &&
        workers[workerObj.phone]!.bookingsTime[dateKey]!.containsKey(timeKey))
      setDate(DateTime(0));
  }

  /// Get: `booking` and add the booking locally to the worker
  static void addBookingToWorkerLocally(Booking booking) {
    final date = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    final time = DateFormat('HH:mm').format(booking.bookingDate);
    if (workers.containsKey(booking.workerId)) {
      final worker = workers[booking.workerId]!;

      if (worker.bookingObjects.containsKey(date)) {
        worker.bookingObjects[date]![booking.bookingId] = booking;
      } else {
        worker.bookingObjects[date] = {booking.bookingId: booking};
      }
      if (worker.bookingsTime.containsKey(date)) {
        worker.bookingsTime[date]![time] = booking.treatment.totalMinutes;
      } else {
        worker.bookingsTime[date] = {time: booking.treatment.totalMinutes};
      }
      SettingsData.workers[worker.phone] = worker;
    }
  }

  /// Get: `booking` and delete the booking locally from the worker
  static void delteBookingFromWorkerLocally(Booking booking) {
    final date = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    final time = DateFormat('HH:mm').format(booking.bookingDate);
    if (BookingProvider.workers.containsKey(booking.workerId)) {
      final worker = BookingProvider.workers[booking.workerId]!;
      if (worker.bookingObjects.containsKey(date) &&
          worker.bookingObjects[date]!.containsKey(booking.bookingId)) {
        worker.bookingObjects[date]!.remove(booking.bookingId);
      }
      if (worker.bookingsTime.containsKey(date) &&
          worker.bookingsTime[date]!.containsKey(time)) {
        worker.bookingsTime[date]!.remove(time);
      }
      SettingsData.workers[worker.phone] = worker;
    }
  }

  void updateScreen() => notifyListeners();

  static WorkerModel? get getWorker {
    if (workers.containsKey(workerPhone)) {
      return workers[workerPhone]!;
    }
    return null;
  }
}
