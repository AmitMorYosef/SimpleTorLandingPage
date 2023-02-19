import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheStorage {
  static SharedPreferences? prefs;

  static Future<void> initialService() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveString(
      {required String value, required String key}) async {
    if (key == '' || value == '') return true;
    return await prefs!.setString(key, value);
  }

  static String getString({required String key}) {
    return prefs!.getString(key) ?? '';
  }

  static Future<bool> removekey(String key) async {
    return await prefs!.remove(key);
  }

  static Future<void> deleteStorage() async {
    await prefs!
        .getKeys()
        .map((key) async => await prefs!.remove(key))
        .toList();
  }

  // static Future<bool> saveBooking(Booking booking) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> data = [
  //     booking.buisnessId,
  //     booking.workerName,
  //     booking.bookingDate.toIso8601String(),
  //     booking.treatmentName,
  //     "${booking.treatmentMinutes}",
  //     "${booking.treatmentPrice}",
  //     booking.customerName,
  //     booking.customerPhone,
  //     booking.workerId,
  //     bookingsMassage[booking.status] ?? "approved"
  //   ];
  //   return await prefs.setStringList(booking.bookingId, data);
  // }

  // static Future<List<Booking>> getBookings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<Booking> bookings = [];
  //   prefs.getKeys().forEach((element) {
  //     List<String> dataList = prefs.getStringList(element) ?? [];
  //     Booking booking = Booking(
  //       bookingId: element,
  //       buisnessId: dataList[0],
  //       workerName: dataList[1],
  //     );
  //     booking.bookingDate = DateTime.parse(dataList[2]);
  //     booking.treatmentName = dataList[3];
  //     booking.treatmentMinutes = int.parse(dataList[4]);
  //     booking.treatmentPrice = int.parse(dataList[5]);
  //     booking.customerName = dataList[6];
  //     booking.customerPhone = dataList[7];
  //     booking.workerId = dataList[8];
  //     booking.status =
  //         bookingsMassageKeys[dataList[9]] ?? BookingStatuses.approved;
  //     bookings.add(booking);
  //   });
  //   return bookings;
  // }

}
