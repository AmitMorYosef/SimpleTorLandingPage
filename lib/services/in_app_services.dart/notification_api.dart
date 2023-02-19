import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../app_const/platform.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails('channel id', 'channel name',
            importance: Importance.max, icon: "@mipmap/ic_launcher"),
        iOS: DarwinNotificationDetails());
  }

  static Future init({bool initSchedule = false}) async {
    if (isWeb) {
      return;
    }
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) =>
          logger.i("The payload is -> $payload"),
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    await _notifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: ((details) =>
            onNotifications.add(details.payload)));
  }

  static Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    _notifications
        .show(id, title, body, await _notificationDetails(), payload: payload)
        .then((value) => logger.d("Done the notification"));
  }

  static Future showScheduleNotification(
      {required int id,
      String? title,
      String? body,
      String? payload,
      required DateTime scheduleDate}) async {
    tz.initializeTimeZones();
    _notifications
        .zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(scheduleDate, tz.local),
            await _notificationDetails(),
            payload: payload,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime)
        .whenComplete(
            () => logger.i('Schedule a notfication in --> ${scheduleDate}'))
        .onError((error, stackTrace) =>
            logger.e('Notification ERROR ' + error.toString()));
  }

  static Future<void> cancel(int notificationId) async =>
      _notifications.cancel(notificationId);

  static Future<void> cancelAll() async {
    if (!isWeb) _notifications.cancelAll();
  }
}
