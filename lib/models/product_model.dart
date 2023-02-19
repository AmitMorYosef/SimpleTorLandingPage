import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_tor_web/models/price_model.dart';

class ProductModel {
  String description = '';
  Price? price;
  String imageUrl = '';
  String name = '';
  String ewallet = '';
  Timestamp createdAt = Timestamp.fromDate(DateTime.now());

  ProductModel({
    this.name = "",
    this.description = '',
    this.price,
    this.imageUrl = '',
    this.ewallet = '',
  });

  ProductModel.fromProduct(ProductModel product) {
    this.description = product.description;
    this.price = product.price;
    this.imageUrl = product.imageUrl;
    this.name = product.name;
    this.createdAt = product.createdAt;
    this.ewallet = product.ewallet;
  }

  ProductModel.fromJson(Map<String, dynamic> json) {
    this.description = json['description'];
    this.price = Price.fromJson(json['price']);
    this.imageUrl = json['imageUrl'];
    this.name = json['name'];
    this.ewallet = json["ewallet"] ?? '';
    this.createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['price'] = price!.toJson();
    data['imageUrl'] = imageUrl;
    data['name'] = name;
    data['ewallet'] = ewallet;
    data['createdAt'] = createdAt;
    return data;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
