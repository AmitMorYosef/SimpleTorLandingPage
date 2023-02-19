import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_tor_web/app_const/application_general.dart';

import '../../../app_const/platform.dart';
import '../../../app_statics.dart/general_data.dart';

class FirebaseNotifications {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final onNotification = BehaviorSubject<String?>();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // android settings
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings("@mipmap/ic_launcher");
  // ios settings
  static final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) =>
        logger.i("payload is --> $payload"),
  );

  static Future<bool> initialService() async {
    if (isWeb) {
      return true;
    }
    try {
      bool resp = false;
      await getUserPermition();
      // combine the deviceses settings into one initial settings
      InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin);
      // initial the settings
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) =>
            onNotification.add(details.payload),
      );
      // open the listiner for in-App notifications
      openAppNotofications();
      logger.d("Succes to activate the notification");
      return resp;
    } catch (e) {
      logger.e('error accured in notification process --> $e');
      return false;
    }
  }

  static showNotification(Map<String, dynamic> data) async {
    logger.d(data);
    // Map<String, String> convertor = {};
    // final lang = await LanguageProvider.getDeviceLang();
    // final hebrewConvertor = {
    //   "optional": "נגחדנחנהגנדל",
    // };
    // final englishConvertor = {"optional": "Optional"};
    // if (lang == "english") {
    //   convertor = englishConvertor;
    // } else {
    //   convertor = hebrewConvertor;
    // }
    final title = data["title"] as String;
    final body = data["body"] as String;
    await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        await NotificationDetails(
            android: AndroidNotificationDetails(
                'firebase_notifications_channel_id', 'simple_tor_web',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true),
            iOS: DarwinNotificationDetails(presentSound: true)),
        payload: data["shopId"]);
  }

  static Future<void> getUserPermition() async {
    if (!isWeb && !Platform.isIOS) return;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    logger.d('User granted permission: ${settings.authorizationStatus}');
  }

  static void openAppNotofications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Message data: ${message.data}');
      BuildContext? context = GeneralData.generalContext;
      final title = message.data["title"] as String;
      final body = message.data["body"] as String;
      // if (context != null)
      //   inAppMessage(
      //     context: context,
      //     title: title,
      //     body: body,
      //   );
    });
  }

  Future<String> getDeviceFCM() async {
    return await messaging.getToken() ?? '';
  }

  Future<bool> subscribeToTopic({required topic}) async {
    bool resp = false;
    await FirebaseMessaging.instance
        .subscribeToTopic(topic)
        .whenComplete(() => resp = true);
    return resp;
  }

  Future<bool> unsubscribeFromTopic({required topic}) async {
    bool resp = false;
    try {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(topic)
          .whenComplete(() => resp = true);
      return resp;
    } catch (e) {
      logger.e("Error when removing topic --> $topic\nerror is -> $e");
      return true;
    }
  }
}
