import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:simple_tor_web/models/price_model.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

class Treatment {
  late int totalMinutes = 0;
  late Price? price;
  late bool showPrice = true, showTime = true;
  late String name = '';
  Map<String, Map<String, dynamic>> times = {};

  Treatment(
      {this.times = const {},
      this.price,
      this.name = "",
      this.showPrice = true,
      this.showTime = true}) {
    this.totalMinutes = getTotalMinutes();
  }

  bool isEqual(Treatment treatment) {
    return !DeepCollectionEquality().equals(treatment, this);
  }

  int getTotalMinutes() {
    int minutes = 0;
    times.forEach((timeIndex, timeData) {
      minutes += (timeData['duration'] as int) + (timeData['break'] as int);
    });
    return minutes;
  }

  Treatment.fromBookingJson(Map<String, dynamic> json) {
    /*get the tretment detial from booking object*/
    (json['times'] as Map).forEach((timeIndex, timeData) {
      this.times[timeIndex] = {};
      (timeData as Map).forEach((key, value) {
        this.times[timeIndex]![key] = value;
      });
    });
    this.price = Price.fromJson(json['price']);
    this.name = json['name'];
    this.totalMinutes = getTotalMinutes();
    this.showPrice = false;
    this.showTime = false;
  }

  Treatment.fromTreatment(Treatment treatment) {
    /*get the tretment detial from booking object*/
    this.times = {...treatment.times};
    this.showTime = treatment.showTime;
    this.showPrice = treatment.showPrice;
    this.price = treatment.price;
    this.name = treatment.name;
    this.totalMinutes = treatment.totalMinutes;
  }

  Map<String, dynamic> toBookingJson() {
    final Map<String, dynamic> data = {};
    data['times'] = times;
    data['price'] = price!.toJson();
    data['name'] = name;
    return data;
  }

  Map<String, dynamic> toLocalFileBookingJson() {
    final Map<String, dynamic> data = {};
    data['times'] = times;
    data['price'] = price!.toJson();
    data['name'] = name;
    return data;
  }

  String priceToString() {
    return price.toString();
  }

  String minutesToString() => durationToString(Duration(minutes: totalMinutes));

  Treatment.fromJson(Map<String, dynamic> json, String key) {
    (json['times'] as Map).forEach((timeIndex, timeData) {
      this.times[timeIndex] = {};
      (timeData as Map).forEach((key, value) {
        this.times[timeIndex]![key] = value;
      });
    });
    this.name = key;
    this.price = Price.fromJson(json['price']);
    this.showPrice = json['showPrice'];
    this.showTime = json['showTime'];
    this.totalMinutes = getTotalMinutes();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['times'] = times;
    data['price'] = price!.toJson();
    data['showPrice'] = showPrice;
    data['showTime'] = showTime;
    return data;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
