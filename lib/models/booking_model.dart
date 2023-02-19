import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:simple_tor_web/models/treatment_model.dart';
import 'package:simple_tor_web/models/worker_model.dart';
import 'package:simple_tor_web/services/external_services/firebase_notifications.dart';
import 'package:uuid/uuid.dart';

import '../app_const/booking.dart';
import '../app_const/gender.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/user_data.dart';
import '../app_statics.dart/worker_data.dart';

class Booking {
  String customerName = '';
  String customerPhone = '';
  String buisnessId = "";
  DateTime bookingDate = DateTime(0);
  String note = "";
  Treatment treatment = Treatment();
  String businessName = "";
  String workerId = '';
  String workerName = '';
  Gender userGender = Gender.anonymous, workerGender = Gender.anonymous;
  BookingStatuses status = BookingStatuses.approved;
  String bookingId = '';
  String deviceFCM = '';
  DateTime createdAt = DateTime.now();
  String anonymousDocId = '';

  Booking(
      {this.customerName = '',
      this.customerPhone = '',
      this.workerGender = Gender.anonymous,
      this.userGender = Gender.anonymous,
      this.workerId = '',
      this.workerName = '',
      this.businessName = "",
      this.buisnessId = '',
      this.bookingId = '',
      this.status = BookingStatuses.approved,
      this.deviceFCM = '',
      this.anonymousDocId = ''});

  Booking.fromBooking(Booking booking) {
    this.workerGender = booking.workerGender;
    this.customerName = booking.customerName;
    this.customerPhone = booking.customerPhone;
    this.note = booking.note;
    this.userGender = booking.userGender;
    this.businessName = booking.businessName;
    this.bookingDate = booking.bookingDate;
    this.workerId = booking.workerId;
    this.bookingId = booking.bookingId;
    this.treatment = Treatment.fromTreatment(booking.treatment);
    this.status = booking.status;
    this.createdAt = booking.createdAt;
    this.workerName = booking.workerName;
    this.buisnessId = booking.buisnessId;
    this.deviceFCM = booking.deviceFCM;
    this.anonymousDocId = booking.anonymousDocId;
  }

  Booking.fromJson(Map<String, dynamic> json) {
    workerGender = genderFromStr[json['workerGender']]!;
    customerName = json['customerName'];
    note = json["note"] ?? "";
    if (json['userGender'] != null) {
      userGender = genderFromStr[json['userGender']]!;
    }
    customerPhone = json['customerPhone'];
    status = bookingsMassageKeys[json['status'].toString()]!;
    bookingDate = DateTime.parse(json['bookingDate']);
    treatment = Treatment.fromBookingJson(json["treatment"]);
    workerId = json["workerId"];
    bookingId = json['bookingId'];
    workerName = json["workerName"];
    businessName = json["businessName"];
    buisnessId = json["buisnessId"];
    deviceFCM = json['deviceFCM'];
    anonymousDocId = json["anonymousDocId"] ?? '';
    createdAt = DateTime.parse(json['createdAt']);
  }

  // Booking.fromJsonToWorkerBooking(Map<String, dynamic> json) {
  //   //workerGender = genderFromStr[json['workerGender']]!;
  //   customerName = json['customerName'];
  //   note = json["note"] ?? "";
  //   if (json['userGender'] != null) {
  //     userGender = genderFromStr[json['userGender']]!;
  //   }
  //   customerPhone = json['customerPhone'];
  //   status = bookingsMassageKeys[json['status'].toString()]!;
  //   bookingDate = DateTime.parse(json['bookingDate']);
  //   treatment = Treatment.fromBookingJson(json["treatment"]);
  //   workerId = json["workerId"];
  //   bookingId = json['bookingId'];
  //   //workerName = json["workerName"];
  //   //businessName = json["businessName"];
  //   buisnessId = json["buisnessId"];
  //   deviceFCM = json['deviceFCM'];
  //   anonymousDocId = json["anonymousDocId"] ?? '';
  //   createdAt = DateTime.parse(json['createdAt']);
  // }

// Booking.fromJsonToUserBooking(Map<String, dynamic> json) {
//     workerGender = genderFromStr[json['workerGender']]!;
//     //customerName = json['customerName'];
//     //note = json["note"] ?? "";
//     // if (json['userGender'] != null) {
//     //   userGender = genderFromStr[json['userGender']]!;
//     // }
//     customerPhone = json['customerPhone'];
//     status = bookingsMassageKeys[json['status'].toString()]!;
//     bookingDate = DateTime.parse(json['bookingDate']);
//     treatment = Treatment.fromBookingJson(json["treatment"]);
//     workerId = json["workerId"];
//     bookingId = json['bookingId'];
//     workerName = json["workerName"];
//     businessName = json["businessName"];
//     buisnessId = json["buisnessId"];
//     //deviceFCM = json['deviceFCM'];
//     //anonymousDocId = json["anonymousDocId"] ?? '';
//     createdAt = DateTime.parse(json['createdAt']);
//   }

  Map<String, int> getBookingWorkTimes() {
    Map<String, int> bookingWorkTimes = {};
    DateTime lastTime = bookingDate;
    treatment.times.forEach((timeIndex, timeData) {
      bookingWorkTimes[DateFormat('HH:mm').format(lastTime)] =
          timeData['duration'] as int;
      // jumping to the end of the segment
      lastTime = lastTime.add(Duration(minutes: timeData['duration'] as int));
      // addint the break after segment
      lastTime = lastTime.add(Duration(minutes: timeData['break'] as int));
    });
    return bookingWorkTimes;
  }

  /// put the extra relevant data before ordering the booking
  Future<void> copyDataToOrder(
      WorkerModel worker, bool isWorkerOrder, bool needToHoldOn) async {
    if (this.customerName == '') this.customerName = UserData.user.name;
    this.workerId = worker.phone;
    this.workerName = worker.name;
    this.workerGender = worker.gender;
    this.businessName = SettingsData.settings.shopName;
    this.bookingId = this.bookingId == '' ? Uuid().v1() : this.bookingId;
    this.buisnessId = SettingsData.appCollection;
    this.userGender = UserData.user.gender;
    if (!isWorkerOrder) {
      //&& DeviceProvider.isAllowedNotification) {ask shilo
      // in case of worker booking for client - dont save the fcm
      this.deviceFCM = await FirebaseNotifications().getDeviceFCM();
    }
    if (isWorkerOrder && this.customerPhone != UserData.user.phoneNumber) {
      /*Worker make a booking from his schedule */
      this.userGender = Gender.anonymous;
    }
    // if (booking.anonymousDocId == '')
    //   booking.anonymousDocId = UserProvider.user.anonymousDocId;
    try {
      this.treatment.price =
          WorkerData.worker.treatments[this.treatment.name]!.price;
    } catch (e) {}
    if (!isWorkerOrder && needToHoldOn) {
      this.status = BookingStatuses.waiting;
    } else {
      this.status = BookingStatuses.approved;
    }
  }

  bool isTheSameAs(Booking booking) {
    return this.bookingDate == booking.bookingDate &&
        this.workerId == booking.workerId &&
        this.treatment.name == booking.treatment.name;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workerGender'] = genderToStr[workerGender];
    data['customerName'] = customerName;
    data["note"] = note;
    data["userGender"] = genderToStr[userGender];
    data["businessName"] = businessName;
    data["treatment"] = treatment.toBookingJson();
    data['customerPhone'] = customerPhone;
    data['status'] = bookingsMassage[status];
    data['bookingId'] = bookingId;
    data['bookingDate'] = bookingDate.toIso8601String();
    data["workerId"] = workerId.toString();
    data["workerName"] = workerName;
    data["buisnessId"] = buisnessId;
    data["deviceFCM"] = deviceFCM;
    data["anonymousDocId"] = anonymousDocId;
    data['createdAt'] = createdAt.toIso8601String();
    return data;
  }

  Map<String, dynamic> toFileLocalJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerName'] = customerName;
    data["note"] = note;
    data["userGender"] = genderToStr[userGender];
    data["treatment"] = treatment.toBookingJson();
    data['customerPhone'] = customerPhone;
    data['bookingDate'] = bookingDate.toIso8601String();
    data["workerId"] = workerId.toString();
    data['createdAt'] = createdAt.toIso8601String();
    return data;
  }

  // Map<String, dynamic> toUserBookingJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['workerGender'] = genderToStr[workerGender];
  //   //data['customerName'] = customerName;
  //   //data["note"] = note;
  //   //data["userGender"] = genderToStr[userGender];
  //   data["businessName"] = businessName;
  //   data["treatment"] = treatment.toBookingJson();
  //   data['customerPhone'] = customerPhone;
  //   data['status'] = bookingsMassage[status];
  //   data['bookingId'] = bookingId;
  //   data['bookingDate'] = bookingDate.toIso8601String();
  //   data["workerId"] = workerId.toString();
  //   data["workerName"] = workerName;
  //   data["buisnessId"] = buisnessId;
  //   //data["deviceFCM"] = deviceFCM;
  //   //data["anonymousDocId"] = anonymousDocId;
  //   data['createdAt'] = createdAt.toIso8601String();
  //   return data;
  // }
  // Map<String, dynamic> toWorkerBookingJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   //data['workerGender'] = genderToStr[workerGender];
  //   data['customerName'] = customerName;
  //   data["note"] = note;
  //   data["userGender"] = genderToStr[userGender];
  //   data["businessName"] = businessName;
  //   data["treatment"] = treatment.toBookingJson();
  //   data['customerPhone'] = customerPhone;
  //   data['status'] = bookingsMassage[status];
  //   data['bookingId'] = bookingId;
  //   data['bookingDate'] = bookingDate.toIso8601String();
  //   data["workerId"] = workerId.toString();
  //   //data["workerName"] = workerName;
  //   data["buisnessId"] = buisnessId;
  //   data["deviceFCM"] = deviceFCM;
  //   //data["anonymousDocId"] = anonymousDocId;
  //   data['createdAt'] = createdAt.toIso8601String();
  //   return data;
  // }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
