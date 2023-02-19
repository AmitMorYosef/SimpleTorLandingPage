import 'dart:convert';

class BreakModel {
  String title = '';
  int color = 0;
  late Duration duration;
  late String day;
  late String start;
  late String note;
  late String id;

  BreakModel(
      {required this.title,
      required this.day,
      required this.start,
      required this.note,
      required this.color,
      required this.duration}) {
    this.id = "${this.day}T${this.start}";
  }

  BreakModel.fromJson(Map<String, dynamic> json, String key) {
    this.id = key;
    this.title = json['title'];
    this.day = key.split('T')[0];
    this.note = json["note"];
    this.start = key.split('T')[1];
    this.color = json['color'];
    this.duration = Duration(minutes: json['duration']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['color'] = color;
    data["note"] = note;
    data['duration'] = duration.inMinutes;
    return data;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
