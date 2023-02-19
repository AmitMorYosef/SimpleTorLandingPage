import '../../app_const/application_general.dart';
import '../../app_const/db.dart';
import '../external_services/firebase_notifications.dart';
import '../external_services/firestore.dart';

class FirebaseNotificationsClient {
  static final FirebaseNotificationsClient _singleton =
      FirebaseNotificationsClient._internal();

  final FirebaseNotifications _notifications = FirebaseNotifications();
  final FirestoreDataBase firestoreDataBase = FirestoreDataBase();

  FirebaseNotificationsClient._internal();

  factory FirebaseNotificationsClient() {
    FirebaseNotificationsClient object = _singleton;
    return object;
  }

  Future<bool> subToNotification(
      {required String topic,
      required String dbStrObject,
      required String uperPhone,
      required String notiType}) async {
    try {
      return await _notifications
          .subscribeToTopic(topic: topic)
          .then((value) async {
        logger.i("Notification status --> $value");
        if (value) {
          final batch = firestoreDataBase.batch;
          firestoreDataBase.updateFieldInsideDocAsArray(
              batch: batch,
              path: usersCollection,
              docId: uperPhone,
              fieldName: 'subToNotifications.$notiType',
              value: dbStrObject);
          firestoreDataBase.commmitBatch(batch: batch);
        }
        return value;
      });
    } catch (e) {
      logger.d("Error while sub to notification --> $e");
      return false;
    }
  }

  Future<bool> unSubFromNotification(
      {required String topic,
      required String dbStrObject,
      required String userPhone,
      required String notiType}) async {
    return await _notifications
        .unsubscribeFromTopic(topic: topic)
        .then((value) async {
      logger.i("Notification status --> $value");
      if (value) {
        final batch = firestoreDataBase.batch;
        firestoreDataBase.updateFieldInsideDocAsArray(
            batch: batch,
            path: usersCollection,
            docId: userPhone,
            fieldName: 'subToNotifications.$notiType',
            command: ArrayCommands.remove,
            value: dbStrObject);
        firestoreDataBase.commmitBatch(batch: batch);
      }
      return value;
    });
  }

  Future<bool> deviceSubToAllNotifications(
      {required List<String> notifications}) async {
    bool resp = true;
    await Future.wait(notifications.map((topic) async {
      await _notifications
          .subscribeToTopic(topic: topic)
          .then((value) => resp = resp && value);
    }).toList());
    return resp;
  }

  Future<bool> deviceUnSubToAllNotifications(
      {required List<String> notifications}) async {
    bool resp = true;
    await Future.wait(notifications.map((topic) async {
      await _notifications
          .unsubscribeFromTopic(topic: topic)
          .then((value) => resp = resp && value);
    }).toList());
    return resp;
  }

  Future<String> getDeviceFCM() async {
    return await _notifications.getDeviceFCM();
  }
}
