import 'dart:convert';

import 'package:simple_tor_web/models/preview_model.dart';

class BuisnessesPreview {
  late Map<String, Preview> buisnesses = {};

  BuisnessesPreview({buisnesses});

  BuisnessesPreview.fromJson(List<Map<String, dynamic>> collection) {
    collection.forEach((doc) {
      if (doc.containsKey('businesses'))
        doc['businesses'].forEach((id, val) {
          //Map<String, String> buisness = {};
          final preview = Preview.fromJson(val);
          this.buisnesses[id] = preview;
        });
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{"businesses": {}};
    this.buisnesses.forEach((id, preview) {
      data["businesses"][id] = preview;
    });
    return data;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
