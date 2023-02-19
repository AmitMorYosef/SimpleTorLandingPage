import '../external_services/notification_service.dart';

class ServerNotificationsClient {
  static final ServerNotificationsClient _singleton =
      ServerNotificationsClient._internal();

  final NotificationServeice _notiService = NotificationServeice();

  ServerNotificationsClient._internal();

  factory ServerNotificationsClient() {
    ServerNotificationsClient object = _singleton;
    return object;
  }

  Future<bool> notifyCanceldBooking({required String topic}) async {
    return await _notiService.activateWitingListNotification(topic: topic);
  }

  Future<bool> notifyGeneralNotification(
      {required String topic,
      required String msg,
      required String title}) async {
    return await _notiService.activateGeneralNotification(
        topic: topic, msg: msg, title: title);
  }

  Future<bool> notifyApprovedBooking(
      {required String userFCM,
      required String msg,
      required String title}) async {
    return await _notiService.activateFcmNotification(
        registration_token: userFCM, msg: msg, title: title);
  }

  Future<bool> notifyToSpecificUser(
      {required String workerFCM,
      required String title,
      required String content}) async {
    return await _notiService.activateFcmNotification(
        registration_token: workerFCM, msg: content, title: title);
  }
}
