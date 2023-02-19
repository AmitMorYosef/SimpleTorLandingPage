import 'dart:convert';

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
}
