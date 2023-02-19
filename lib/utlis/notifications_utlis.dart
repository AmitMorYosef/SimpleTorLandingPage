// import 'package:flutter/material.dart';
// import 'package:simple_tor_web/app_const/application_general.dart';
// import 'package:simple_tor_web/app_statics.dart/user_data.dart';
// import 'package:simple_tor_web/utlis/string_utlis.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:top_snackbar_flutter/top_snack_bar.dart';

// import '../app_const/booking.dart';
// import '../app_const/notification.dart';
// import '../app_const/platform.dart';
// import '../providers/device_provider.dart';
// import '../providers/user_provider.dart';
// import '../services/in_app_services.dart/notification_api.dart';
// import '../ui/general_widgets/custom_widgets/custom_container.dart';
// import '../ui/general_widgets/dialogs/genral_dialog.dart';

// Future<void> deleteNotification(
//     int minutesBeforeNotify, DateTime notificationDate, int turnMinutes) async {
//   final durationBeforeNotify = Duration(minutes: minutesBeforeNotify);
//   final datesToNotify = [
//     notificationDate.subtract(durationBeforeNotify),
//     notificationDate.add(Duration(minutes: turnMinutes + 2))
//   ];
//   datesToNotify.forEach(
//       (date) async => await NotificationApi.cancel(uniqueIntIdByDate(date)));
// }

// Future<bool> bringBackAllNotifications(
//     bool allowedNotification, int minutesBeforeNotify) async {
//   // if user allow notification we need to restore all the ones we delete before
//   UserData.user.bookings.forEach((key, booking) async {
//     if (booking.status == BookingStatuses.approved) {
//       logger.d("Bring back --> ${booking.bookingDate}");
//       await newNotification(
//           allowedNotification,
//           minutesBeforeNotify,
//           booking.bookingDate,
//           booking.treatment.totalMinutes,
//           booking.businessName);
//     }
//   });
//   logger.d('Brought back all notification');
//   return true;
// }

// Future<void> deleteAllNotifications() async => NotificationApi.cancelAll();

// int uniqueIntIdByDate(DateTime dateTime) {
//   var miliseconds = dateTime.millisecondsSinceEpoch;
//   var stringMiliseconds = miliseconds.toString();
//   var newString = stringMiliseconds.substring(stringMiliseconds.length - 8);
//   return int.parse(newString);
// }

// Future<bool> newNotification(bool allowedNotification, int minutesBeforeNotify,
//     DateTime notificationDate, int turnMinutes, String businessName) async {
//   final durationBeforeNotify = Duration(minutes: minutesBeforeNotify);
//   String userName = UserData.user.name;
//   final beforeBody = translate("hey") +
//       " " +
//       userName +
//       " " +
//       translate("bookingIn") +
//       " " +
//       durationToString(durationBeforeNotify) +
//       " " +
//       translate("getReady");
//   final afterBody = translate("finishBookingMsg");
//   final payload = '';
//   //when add to this map need to add to the delete list in deleteNotification func
//   final datesToNotify = {
//     notificationDate.subtract(durationBeforeNotify): beforeBody,
//     notificationDate.add(Duration(minutes: turnMinutes + 2)): afterBody
//   };

//   if (allowedNotification &&
//       notificationDate.subtract(durationBeforeNotify).isAfter(DateTime.now())) {
//     //make a notification to all dates that in the datesToNotify
//     await Future.forEach(
//         datesToNotify.keys,
//         (date) async => await NotificationApi.showScheduleNotification(
//             id: uniqueIntIdByDate(date),
//             title: businessName,
//             body: datesToNotify[date],
//             payload: payload,
//             scheduleDate: date));

//     return true;
//   } else {
//     logger.d(allowedNotification
//         ? 'Too early to notify'
//         : 'Not allowed notification');
//     return false;
//   }
// }

// void inAppMessage(
//     {required BuildContext context,
//     required String title,
//     required String body}) {
//   showTopSnackBar(
//       Overlay.of(context),
//       Material(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//         color: Theme.of(context).colorScheme.background,
//         child: CustomContainer(
//             padding: EdgeInsets.all(8),
//             needImage: false,
//             color: Theme.of(context).colorScheme.background,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 19),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(body, style: TextStyle(fontSize: 15))
//               ],
//             )),
//       ),
//       dismissType: DismissType.onSwipe);
// }

// Future<bool> deleteNotifications(BuildContext context) async {
//   await deleteAllNotifications();
//   bool resp = await context.read<UserProvider>().deviceTurnOffNotifications();
//   return resp;
// }

// Future<void> onChanged(bool value, BuildContext context) async {
//   context.read<DeviceProvider>().updateIsAllowedNotification(value);
//   if (value) {
//     bringBackAllNotifications(
//         context.read<DeviceProvider>().isAllowedNotification,
//         context.read<DeviceProvider>().minutesBeforeNotify);
//     context.read<UserProvider>().deviceTurnOnNotifications();
//   } else {
//     deleteNotifications(context);
//   }
// }

// Future<void> changeAllowNotificationsStatus(
//     BuildContext context, bool value) async {
//   if (!value) {
//     bool? resp = true;
//     if (UserData.user.subToNotifications[NotifySorts.waitingList]!.isNotEmpty) {
//       resp = await genralDialog(
//         context: context,
//         content: Text(
//           translate("youWillRemoveFromWaitingLists"),
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         title: translate("turnOffNotifications?"),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(translate("no")),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//             child: Text(translate("yes")),
//           ),
//         ],
//       );
//     }
//     if (resp == true) {
//       onChanged(value, context);
//     }
//   } else {
//     checkForNotificationPermission(context, value);
//   }
// }

// Future<void> checkForNotificationPermission(
//     BuildContext context, bool value) async {
//   if (isWeb) {
//     return;
//     //onChanged(value);
//   }
//   var status = await Permission.notification.status;
//   if (status.isGranted) {
//     onChanged(value, context);
//   } else {
//     await genralDialog(
//         context: context,
//         title: translate("noPemission"),
//         content: Text(
//           translate("needToAllowNotificationInSettings"),
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(translate("ok")))
//         ]);
//   }
// }

// Future<void> activateNotificationDialog(BuildContext context) async {
//   await genralDialog(
//       context: context,
//       title: translate("allowedNotificationsTitle"),
//       content: Text(
//         translate("doYouWantToActiveateNotification"),
//         textAlign: TextAlign.center,
//         style: Theme.of(context).textTheme.bodyMedium,
//       ),
//       actions: [
//         TextButton(
//             onPressed: (() => Navigator.pop(context)),
//             child: Text(translate("no"))),
//         TextButton(
//             onPressed: (() {
//               changeAllowNotificationsStatus(context, true);

//               Navigator.pop(
//                 context,
//               );
//             }),
//             child: Text(translate("yes"))),
//       ]);
// }
