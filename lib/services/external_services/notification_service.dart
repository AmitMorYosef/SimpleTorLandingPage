import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/server_variables.dart';

class NotificationServeice {
  Future<bool> activateWitingListNotification({required String topic}) async {
    try {
      Map<String, dynamic> queryParameters = {
        "topic": topic,
      };
      Uri url = Uri.https(SERVER_BASE_URL,
          '$NOTIFICATIONS_END_POINT/waiting_list', {'topic': topic});
      http.Response response = await http
          .post(url, body: jsonEncode(queryParameters))
          .timeout(Duration(seconds: 5));
      logger.i("Response.statusCode:  ${response.statusCode}");
      if (response.statusCode != 200) {
        return false;
      }
      final body = Utf8Decoder().convert(response.bodyBytes);
      Map<String, dynamic> json = jsonDecode(body);
      return json['ok'];
    } catch (e) {
      logger.e("Error while activate the waiting list notification");
      logger.e("Error --> $e");
      return true;
    }
  }

  Future<bool> activateGeneralNotification(
      {required String topic,
      required String msg,
      required String title}) async {
    try {
      Uri url = Uri.https(
          SERVER_BASE_URL,
          "$NOTIFICATIONS_END_POINT/general_message",
          {'topic': topic, 'msg': msg, 'title': title});
      http.Response response =
          await http.post(url).timeout(Duration(seconds: 5));
      logger.i("Response.statusCode:  ${response.statusCode}");
      if (response.statusCode != 200) {
        return false;
      }
      final body = Utf8Decoder().convert(response.bodyBytes);
      Map<String, dynamic> json = jsonDecode(body);
      return json['ok'];
    } catch (e) {
      logger.e("Error while activate the general notification");
      logger.e("Error --> $e");
      return true;
    }
  }

  Future<bool> activateFcmNotification(
      {required String registration_token,
      required String msg,
      required String title}) async {
    try {
      Uri url = Uri.https(
          SERVER_BASE_URL, "$NOTIFICATIONS_END_POINT/specific_notification");
      Map<String, dynamic> queryParameters = {
        "registration_token": registration_token,
        "msg": msg,
        'title': title
      };
      http.Response response = await http
          .post(url, body: jsonEncode(queryParameters))
          .timeout(Duration(seconds: 5));
      logger.i("Response.statusCode:  ${response.statusCode}");
      if (response.statusCode != 200) {
        return false;
      }
      final body = Utf8Decoder().convert(response.bodyBytes);
      Map<String, dynamic> json = jsonDecode(body);
      return json['ok'];
    } catch (e) {
      logger.e("Error while activate the fcm notification");
      logger.e("Error --> $e");
      return true;
    }
  }
}
