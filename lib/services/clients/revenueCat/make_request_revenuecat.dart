import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app_const/application_general.dart';
import '../../../secrets.dart';

class MakeRequestRevenueCat {
  static final MakeRequestRevenueCat _singleton =
      MakeRequestRevenueCat._internal();

  final _baseURL = "https://api.revenuecat.com/v1";

  MakeRequestRevenueCat._internal();

  factory MakeRequestRevenueCat() {
    MakeRequestRevenueCat object = _singleton;
    return object;
  }

  Map<String, String> _generateHeader() {
    var header = {
      "accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer ${purchaseSecretApiKey}"
    };
    return header;
  }

  Future<Map<String, dynamic>?> performRequst({
    required String endpoint,
  }) async {
    final url = Uri.parse(_baseURL + endpoint);

    final headers = _generateHeader();

    final response = await _request(url: url, headers: headers);
    if (response.statusCode == 200) {
      // request succeded
      logger.i('RevenueCat request status -- > Success!');
      Map<String, dynamic> data = Map.castFrom(jsonDecode(response.body));
      return data;
    }
    logger.i('RevenueCat request status -- > Faild!');
    return null;
  }

  Future<dynamic> _request(
      {required Uri url, Map<String, String>? headers}) async {
    return await http.get(
      url,
      headers: headers,
    );
  }
}
