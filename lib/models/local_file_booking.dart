import 'package:management_system_app/models/treatment_model.dart';

import '../app_const/gender.dart';

class LocalFileBooking {
  String customerName = '';
  String customerPhone = '';
  DateTime bookingDate = DateTime(0);
  String note = "";
  Treatment treatment = Treatment();
  String workerId = '';
  Gender userGender = Gender.anonymous;
  DateTime createdAt = DateTime.now();

  LocalFileBooking.fromLocalFileJson(Map<String, dynamic> json) {
    customerName = json['customerName'];
    note = json["note"] ?? "";
    if (json['userGender'] != null) {
      userGender = genderFromStr[json['userGender']]!;
    }
    customerPhone = json['customerPhone'];
    bookingDate = DateTime.parse(json['bookingDate']);
    treatment = Treatment.fromBookingJson(json["treatment"]);
    workerId = json["workerId"];
    createdAt = DateTime.parse(json['createdAt']);
  }
  Map<String, dynamic> toLocalFileJson() {
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
}
