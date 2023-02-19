import 'dart:convert';

import 'package:management_system_app/models/local_file_booking.dart';

import '../../app_const/application_general.dart';
import '../../app_const/booking.dart';
import '../../models/booking_model.dart';
import '../../services/in_app_services.dart/local_file_db.dart';

class LocalFileHelper {
  // -- Local File helper - add, remove and update the local files --

  /// Get: `workerId, dayString and bookingsOfDay`  return true if write successfully to the local file
  Future<bool> addDayToLocalFile(
      {required String workerId,
      required String dayString,
      required Map<String, Booking> bookingsOfDay}) async {
    final Map<String, String> bookings = {};
    bookingsOfDay.forEach((bookingId, booking) {
      if (booking.status == BookingStatuses.approved) {
        bookings[bookingId] = jsonEncode(booking.toFileLocalJson());
      }
    });
    if (bookings.isEmpty) {
      logger.d("Empty bookings not add a file");
      return true;
    }
    return await LocalFileDb().writeToFile(
        fileName: "$workerId---$dayString", content: jsonEncode(bookings));
  }

  /// Get: `workerId, dayString ` return the bookings from the file if exist
  Future<Map<String, LocalFileBooking>?> readDayFromLocalFile({
    required String workerId,
    required String dayString,
  }) async {
    final bookingsJson =
        await LocalFileDb().readFromFile(fileName: "$workerId---$dayString");

    if (bookingsJson != null) {
      logger.d("No file with that name --> $workerId---$dayString");
      return null;
    }

    final Map<String, LocalFileBooking> bookings = {};

    bookingsJson!.forEach((bookingId, booking) {
      bookings[bookingId] = LocalFileBooking.fromLocalFileJson(booking);
    });

    return bookings;
  }
}
