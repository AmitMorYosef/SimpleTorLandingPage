import 'dart:convert';

import 'package:management_system_app/models/user_model.dart';

import '../app_const/gender.dart';

class WaitingListCustomer {
  String name = ''; // str user name
  Gender gender = Gender.anonymous; // enum
  String phonenumber = ''; // str +xx-xxxxx

  WaitingListCustomer({
    this.name = "",
    this.gender = Gender.anonymous,
    this.phonenumber = '',
  });

  WaitingListCustomer.fromJson(dynamic json, {String phone = ''}) {
    this.name = json['N'];
    this.gender = getGender(json['G']);
    this.phonenumber = phone;
  }

  WaitingListCustomer.fromUser(User user) {
    this.name = user.name;
    this.gender = user.gender;
    this.phonenumber = user.phoneNumber;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['N'] = name;
    data['G'] = genderCode;
    //data['phonenumber'] = phonenumber;
    return data;
  }

  String get genderCode {
    // str - M(male), F(female), A(anonymus)
    switch (this.gender) {
      case Gender.male:
        return 'M';
      case Gender.female:
        return 'F';
      case Gender.anonymous:
        return 'A';
    }
  }

  Gender getGender(String code) {
    // str - M(male), F(female), A(anonymus)
    switch (code) {
      case 'M':
        return Gender.male;
      case 'F':
        return Gender.female;
      case 'A':
        return Gender.anonymous;
    }
    return Gender.anonymous;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
