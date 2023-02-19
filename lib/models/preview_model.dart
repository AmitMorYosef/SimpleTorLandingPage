import 'dart:convert';

import 'package:simple_tor_web/services/enums.dart';

class Preview {
  late String address;
  late String buisnessId;
  late String imageUrl;
  late BusinessesTypes businesseType;
  late String name;

  Preview({
    this.address = '',
    this.buisnessId = '',
    this.imageUrl = '',
    this.businesseType = BusinessesTypes.other,
    this.name = '',
  });

  Preview.fromPreview(Preview preview) {
    this.address = preview.address;
    this.buisnessId = preview.buisnessId;
    this.businesseType = preview.businesseType;
    this.imageUrl = preview.imageUrl;
    this.name = preview.name;
  }

  Preview.fromJson(Map<String, dynamic> json) {
    this.address = json['address'];
    this.buisnessId = json['buisnessId'];
    this.imageUrl = json['imageUrl'];
    if (json['businesseType'] == null)
      this.businesseType = BusinessesTypes.other;
    else
      this.businesseType = businessTypeFromStr[json['businesseType']]!;
    this.name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = this.address;
    data['name'] = this.name;
    data['businesseType'] = businessTypeToStr[this.businesseType]!;
    data['buisnessId'] = this.buisnessId;
    data['imageUrl'] = this.imageUrl;
    return data;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
