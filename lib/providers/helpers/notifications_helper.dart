import 'package:intl/intl.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/models/user_model.dart';
import 'package:simple_tor_web/services/clients/firestore_client.dart';

import '../../app_const/booking.dart';
import '../../app_const/notification.dart';
import '../../app_statics.dart/settings_data.dart';
import '../../app_statics.dart/user_data.dart';
import '../../models/booking_model.dart';
import '../../models/notification_topic.dart';
import '../../models/worker_model.dart';
import '../../services/clients/server_notifications_client.dart';
import '../../services/errors_service/app_errors.dart';
import '../../services/errors_service/user.dart';
import '../../utlis/string_utlis.dart';

class NotificationsHelper {
  // -- notifications to worker about user actions [order, delete, update] --

  ///  Get: `worker` that getting ordered.   [booking] object.
  ///       [isWorkerOrder] or the ServerNotificationsClient() order to itself.
  ///
  ///  Execute: send push notifiction if needed
  Future<void> notifyWorkerAboutOrder(
      WorkerModel worker, Booking booking) async {
    if (!_notifyToWorker(worker, booking.customerPhone)) {
      return;
    }
    // finally activate the notification
    await ServerNotificationsClient().notifyToSpecificUser(
      workerFCM: worker.currentFcm,
      content:
          "${booking.customerName} ${translate("ServerNotificationsClient()OrderMessage")} ${translate("toDate").replaceAll('DATE', getFormatedTime(booking.bookingDate))}",
      title: translate("newBooking"),
    );
  }

  /// Get: `booking` and notify the booking customer about deletion of it
  Future<void> notifyWorkerAboutUserBookingDeletion(
    Booking booking,
  ) async {
    WorkerModel? worker = SettingsData.workers[booking.workerId];
    if (!_notifyToWorker(worker, booking.customerPhone)) {
      return;
    }
    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: worker!.currentFcm,
        title: translate("WorkerBookingDeleted"),
        content: translate("WorkerDeletedContent")
            .replaceAll('DATE', getFormatedTime(booking.bookingDate)));
  }

  /// Get: `booking` and notify the booking's customer about change that appened
  Future<void> notifyWorkerAboutUserBookingChanging(
      Booking booking, DateTime newDate) async {
    WorkerModel? worker = SettingsData.workers[booking.workerId];
    if (!_notifyToWorker(worker, booking.customerPhone)) {
      return;
    }
    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: worker!.currentFcm,
        title: translate("WorkerBookingChanged"),
        content: translate("WorkerChangedContent")
            .replaceAll('OLDDATE', getFormatedTime(booking.bookingDate))
            .replaceAll('NEWDATE', getFormatedTime(newDate)));
  }

  // -- notifications to user about worker actions [order, delete, update] --

  /// Get: `booking` and notify the booking customer about deletion of it
  Future<void> notifyWorkerOrderedBooking(Booking booking) async {
    if (booking.deviceFCM == '') {
      return; // enable to notify - there isn't fcm
    }
    if (UserData.user.phoneNumber == booking.customerPhone) {
      return; // the user deleting to himself not the worker
    }
    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: booking.deviceFCM,
        title: translate("bookingOrdered"),
        content: translate("bookingOrderedContent")
            .replaceAll('DATE', getFormatedTime(booking.bookingDate))
            .replaceAll("WORKERNAME", booking.workerName));
  }

  /// Get: `booking` and notify the booking customer about deletion of it
  Future<void> notifyWorkerDeletedBooking(Booking booking) async {
    if (booking.deviceFCM == '') {
      return; // enable to notify - there isn't fcm
    }
    if (UserData.user.phoneNumber == booking.customerPhone) {
      return; // the user deleting to himself not the worker
    }
    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: booking.deviceFCM,
        title: translate("bookingDeleted"),
        content: translate("bookingDeletedContent")
            .replaceAll('DATE', getFormatedTime(booking.bookingDate)));
  }

  /// Get: `booking` and notify the booking customer about change that appened
  Future<void> notifyWorkerChangedBooking(
      Booking booking, DateTime newDate) async {
    if (booking.deviceFCM == '') {
      return; // enable to notify - there isn't fcm
    }
    if (UserData.user.phoneNumber == booking.customerPhone) {
      return; // to user changing to himself not the worker
    }
    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: booking.deviceFCM,
        title: translate("bookingChangedTitle"),
        content: translate("bookingChangedContent")
            .replaceAll('OLDDATE', getFormatedTime(booking.bookingDate))
            .replaceAll('NEWDATE', getFormatedTime(newDate)));
  }

  /// Get: `user, worker and businessId` notify when user first time
  /// enter the business
  Future<void> notifyFirstTimeEnterBusiness(WorkerModel worker, User user,
      String businessId, String businessName, bool needNotify) async {
    if (!UserData.isConnected()) {
      return; // no need to notify about guests
    }
    if (!needNotify) {
      return; // no need to notify
    }
    /*Combine the two last visited maps */
    final visitedBusinesses = {...UserData.user.lastVisitedBuisnesses};
    visitedBusinesses.addAll({...UserData.user.lastVisitedBuisnessesRemoved});
    if (visitedBusinesses.contains(businessId)) {
      return; // user already visited
    }

    if (worker.currentFcm == '') {
      return; // enable to notify - there isn't fcm
    }

    if (worker.phone == user.phoneNumber) {
      return; //same user not need notify
    }

    logger.i("Send notifyFirstTimeEnterBusiness to --> ${worker.phone}");
    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: worker.currentFcm,
        title: translate("newCustomer"),
        content: translate("newCustomerContent")
            .replaceAll("BUSINESS_NAME", businessName)
            .replaceAll('NAME', user.name)
            .replaceAll('DATE', getFormatedTime(DateTime.now())));
  }

  // ----------- notifications to wating list topic -------------------

  /// Get:  and notify the waiting list about new times to order
  Future<void> notifyWaitingListAboutNewTimes(Booking booking) async {
    String bookingDate = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    await ServerNotificationsClient().notifyCanceldBooking(
        topic: NotificationTopic(
                businessId: booking.buisnessId,
                workerId: booking.workerId,
                date: bookingDate,
                workerName: booking.workerName)
            .toTopicStr());
  }

  //-------------- notifications on waiting lists events -------------------

  /// Get: `userName, workerFcm, workerId and date` and notify to
  /// worker that user added  to his waiting list
  Future<void> notifyWorkerOnUserAddedToWaitingList(
      {required WorkerModel worker,
      required String userName,
      required DateTime date,
      required String userPhone}) async {
    if (worker.currentFcm == '') {
      return; // enable to notify - there isn't fcm
    }
    if (worker.phone == userPhone) {
      return; // worker book for himself
    }
    if (!worker.notifyOnWaitingListEvents) {
      return; //worker doesnt want to get notifications about waiting list
    }

    await ServerNotificationsClient().notifyToSpecificUser(
        workerFCM: worker.currentFcm,
        title: translate("waitingListUpdate"),
        content: translate("notifyOnWaitingListContent")
            .replaceAll('NAME', userName)
            .replaceAll('DATE', DateFormat("dd-MM-yyyy").format(date)));
  }

  // -------------- local notifications to user [set, delete] ---------------

  /// Get: `booking` and set device local notification if needed
  Future<bool> setLocalBookingNotification(
    Booking booking,
    bool allowedNotification,
    int minutesBeforeNotify,
  ) async {
    if (booking.status == BookingStatuses.approved) {
      // return await newNotification(
      //     allowedNotification,
      //     minutesBeforeNotify,
      //     booking.bookingDate,
      //     booking.treatment.totalMinutes,
      //     SettingsData.settings.shopName);
    }
    return false;
  }

  /// Get: `booking` and remove device local notification if needed
  Future<void> deleteLocalBookingNotification(
    Booking booking,
    int minutesBeforeNotify,
  ) async {
    if (UserData.user.phoneNumber == booking.customerPhone) {
      // await deleteNotification(minutesBeforeNotify, booking.bookingDate,
      //     booking.treatment.totalMinutes);
      // ;
    }
  }

  // ----------------- remove expired notification --------------------------

  /// remove the expired waiting list Notifications from the current user
  Future<void> removeExpiredSubNotifications() async {
    User user = UserData.user;
    AppErrors.addError(
        code: userCodeToInt[UserErrorCodes.removeExpiredSubNotifications]);
    List<String> notiStrs = [
      ...user.subToNotifications[NotifySorts.waitingList]!.values
    ];
    DateTime now = DateFormat('dd-MM-yyyy')
        .parse(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    await Future.wait(notiStrs.map((element) async {
      if (element.length > 11) {
        NotificationTopic notificationTopic =
            NotificationTopic.fromTopicStr(element);
        if (DateFormat('dd-MM-yyyy')
            .parse(notificationTopic.date)
            .isBefore(now))
          return await FirestoreClient()
              .unSubFromNotification(
                  notiType: notifySortsToStr[NotifySorts.waitingList]!,
                  topic: notificationTopic.toTopicStr(),
                  dbStrObject: notificationTopic.toStrObject(),
                  userPhone: user.phoneNumber)
              .then((value) {
            if (value) {
              user.subToNotifications[NotifySorts.waitingList]!
                  .remove(notificationTopic.toTopicStr());
            }
            return value;
          });
      }
    }).toList());
  }

  /// remove deleted businesses notifications from the current user
  Future<void> removeDeletedBuisnessesSubNotifications() async {
    // AppErrors.addError(
    //     code: userCodeToInt[
    //         UserErrorCodes.removeDeletedBuisnessesSubNotifications]);
    /*
    TODO: check if business dosent exist remove the notification
     */
    // List<String> notiStrs = user.subToNotifications[NotifySorts.buisness]!;
    // await Future.wait(notiStrs.map((element) async {
    //   if (element.length > 11) {
    //     if (!SettingsData.buisnessesPreview.buisnesses.containsKey(
    //         NotificationTopic.fromTopicStr(element).businessId))
    //       return await ServerNotificationsClient().unSubFromNotification(
    //           notiType: notifySortsToStr[NotifySorts.buisness]!,
    //           topic: element,
    //           userPhone: user.phoneNumber);
    //   }
    // }).toList());
  }

  // ------------------------------- utilis ----------------------------------
  bool _notifyToWorker(WorkerModel? worker, String customerPhone) {
    if (worker == null) {
      return false;
    }
    bool isWorkerOrder = UserData.user.phoneNumber == worker.phone;
    if (!worker.notifyWhenGettingBooking) {
      return false; // the worker dosen't allow notifications while ordering
    }
    if (worker.currentFcm == "") {
      return false; // imposible to notify there isn't fcm
    }
    if (isWorkerOrder) {
      return false; // the worker perform the order from scedule for ServerNotificationsClient()
    }
    if (worker.phone == customerPhone) {
      return false; // worker order to himself
    }
    return true;
  }

  String getFormatedTime(DateTime date) {
    final day = DateFormat('dd-MM-yyyy').format(date);
    final time = DateFormat('HH:mm').format(date);
    String templete = "DATE IN TIME";
    return templete
        .replaceAll('DATE', day)
        .replaceAll('TIME', time)
        .replaceAll('IN', translate("at"));
  }
}
