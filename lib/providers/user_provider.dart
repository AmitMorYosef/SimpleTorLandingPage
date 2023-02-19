import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/providers/helpers/notifications_helper.dart';
import 'package:simple_tor_web/providers/login_provider.dart';
import 'package:simple_tor_web/services/clients/firebase_real_time_client.dart';
import 'package:simple_tor_web/services/errors_service/app_errors.dart';
import 'package:simple_tor_web/services/errors_service/user.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:uuid/uuid.dart';

import '../app_const/db.dart';
import '../app_const/gender.dart';
import '../app_const/limitations.dart';
import '../app_const/notification.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/user_data.dart';
import '../app_statics.dart/worker_data.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/worker_model.dart';
import '../services/clients/firebase_auth_client.dart';
import '../services/clients/firestore_client.dart';
import '../services/errors_service/messages.dart';
import '../services/in_app_services.dart/calendar.dart';
import '../utlis/times_utlis.dart';
import 'booking_provider.dart';
import 'helpers/db_pathes_helper.dart';

class UserProvider extends ChangeNotifier {
  Future<bool> setupUser(
      {String? phone, bool logoutIfDosentExist = true}) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.setupUser]);

    String userPhone =
        phone ?? FirebaseAuthClient().getUserPhone(); // deleted buisnesses
    logger.i("The user phone is -> $userPhone");
    if (userPhone.length < 5) {
      await FirebaseAuthClient().logout();
      return true; // to not despaly error
    }

    /*If user came from loggin his doc already in the userDoc 
      and there is no need to read again from db*/
    if (UserData.userDoc == null) {
      UserData.userDoc = await FirestoreClient()
          .getDoc(path: usersCollection, docId: userPhone);
    }
    if (!logoutIfDosentExist && !UserData.userDoc!.exists) {
      UserData.userDoc = null;
      return true; // new user logg-in and not register yet -> leave him logged-in
    }
    try {
      if (!UserData.userDoc!.exists) {
        try {
          logger.i("User doc isn't found --> loggin the user out!");
          await FirebaseAuthClient().logout();
          return true; // to not despaly error
        } catch (e) {
          logger.e("Error while log the user out --> $e");
          AppErrors.addError(error: Errors.notFoundItem);
          return false;
        }
      }

      UserData.user = User.fromUserDocJson(UserData.userDoc!.data()!);
      /*initialize the user Doc*/
      UserData.userDoc = null;

      /*No need to take the user public data the startListening 
        func will take it*/
      UserData.startPublicDataListening();

      NotificationsHelper().removeExpiredSubNotifications();
      NotificationsHelper().removeDeletedBuisnessesSubNotifications();
      /*need to clean the data only after getting the current data*/
      _cleanExpiredData();
      //add the user preview to the businesses previews
      SettingsData.buisnessesPreview.buisnesses.addAll(UserData.user.previews);
      // clean the deleted buisnesses from user

      UiManager.insertUpdate(Providers.user);
      return true;
    } catch (e) {
      /*initialize the user Doc*/
      UserData.userDoc = null;
      logger.e("Error while setup the user --> $e");
      AppErrors.addError(details: e.toString());
      return false;
    }
  }

  Future<void> _cleanExpiredData() async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.cleanExpiredData]);
    DateTime lastClean = UserData.user.lastCleanDate.toDate();
    logger.i("Last clean is --> $lastClean");
    if (lastClean.add(durationToCleanUserData).isAfter(DateTime.now())) {
      /*user is already up to date no need to delete the expired data*/
      return;
    }
    logger.d("Start to update the user bookings");

    /*make sure the data is in the user*/
    await FirestoreClient()
        .getDoc(
      path: "$usersCollection/${UserData.user.phoneNumber}/$dataCollection",
      docId: dataDoc,
    )
        .then(
      (snapshot) {
        if (snapshot.exists) {
          UserData.user.setUserPublicData(snapshot.data()!);
        }
      },
    );

    /*The data that toPublicDataJson give is already 
      up to date no need to check again */
    await FirestoreClient()
        .setDoc(
            path:
                "$usersCollection/${UserData.user.phoneNumber}/$dataCollection",
            docId: dataDoc,
            valueAsJson: UserData.user.toPublicDataJson())
        .then(
      (value) async {
        if (value) {
          /*update the lastCleanDate to today */
          await FirestoreClient()
              .updateFieldInsideDocAsMap(
                  path: usersCollection,
                  docId: UserData.user.phoneNumber,
                  fieldName: "lastCleanDate",
                  value: Timestamp.fromDate(DateTime.now()))
              .then((value) {
            if (value) {
              /*update the last clean date locally*/
              UserData.user.lastCleanDate = Timestamp.fromDate(DateTime.now());
            }
          });
        }
        return value;
      },
    );
  }

  Future<bool> createUser(
      BuildContext context, Gender gender, String phone) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.createUser]);
    LogginProvider logginProvider = context.read<LogginProvider>();
    final currentUser = User(
        name: logginProvider.userNameController.text,
        phoneNumber: phone,
        myBuisnessesIds: [],
        productsIds: {},
        lastVisitedBuisnessesRemoved: [],
        lastVisitedBuisnesses: [],
        subToNotifications: {},
        revenueCatId: Uuid().v1(),
        gender: gender);
    return await FirestoreClient()
        .createDoc(
            path: usersCollection,
            docId: phone,
            valueAsJson: currentUser.toUserDocJson())
        .then((value) async {
      if (value) {
        return await FirestoreClient()
            .createDoc(
                path: "$usersCollection/$phone/$dataCollection",
                docId: dataDoc,
                valueAsJson: currentUser.toPublicDataJson())
            .then((value) {
          //UserData..user = user;
          return value;
        });
      }
      return value;
    });
  }

  Future<bool> deleteUser(User user) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.deleteUser]);
    return await FirestoreClient()
        .deleteDoc(
            path: "$usersCollection/${user.phoneNumber}/$dataCollection",
            docId: dataDoc)
        .then((value) async {
      if (value) {
        return await FirestoreClient()
            .deleteDoc(path: usersCollection, docId: UserData.user.phoneNumber);
      }
      return value;
    });
  }

  Future<bool> logout({bool includeUpdetUiInsert = true}) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.logout]);
    return await FirebaseAuthClient().logout().then((value) async {
      if (value) {
        await UserData.cancelPublicDataListening();
        UserData.user = User(
          name: "guest",
          myBuisnessesIds: [],
          productsIds: {},
          lastVisitedBuisnessesRemoved: [],
          lastVisitedBuisnesses: [],
          subToNotifications: {},
        );

        if (includeUpdetUiInsert) {
          UiManager.insertUpdate(Providers.settings); // update pages manager
        }
      } else {
        logger.i('Error log the user out');
      }
      return value;
    });
  }

// ---------------------------------- visited busiensses ---------------------------

  Future<void> replaceVisitedBuisness(
      String oldBuisnessId, String newBuisnessId) async {
    /* update the list of the last visited buisnesses to make it sorted any time
    the user is loading a new buisness -> don't need to return value, it can 
    accure in the background if it faile -> dosen't important.
    */
    AppErrors.addError(
        code: userCodeToInt[UserErrorCodes.replaceVisitedBuisness]);
    //we dont need to access the data base there is no change
    if (UserData.user.lastVisitedBuisnesses.contains(newBuisnessId) &&
        UserData.user.lastVisitedBuisnesses.last == newBuisnessId) {
      logger.i("There is no need to access the data base ");
      return;
    }

    UserData.user.lastVisitedBuisnesses.remove(oldBuisnessId);
    UserData.user.lastVisitedBuisnesses.add(newBuisnessId);

    await FirestoreClient().updateFieldInsideDocAsMap(
        path: usersCollection,
        docId: UserData.user.phoneNumber,
        fieldName: "lastVisitedBuisnesses",
        value: UserData.user.lastVisitedBuisnesses);
  }

  Future<void> addVisitedBuisness(String buisnessId) async {
    /* update the list of the last visited buisnesses to make it sorted any time
    the user is loading a new buisness -> don't need to return value, it can 
    accure in the background if it faile -> dosen't important.
    */
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.addVisitedBuisness]);
    if (UserData.user.phoneNumber == '') return;
    if (UserData.user.lastVisitedBuisnessesRemoved.contains(buisnessId)) {
      await FirestoreClient().updateMultipleFieldsInsideDocAsArray(
          path: usersCollection,
          docId: UserData.user.phoneNumber,
          data: {
            "lastVisitedBuisnesses": {
              "command": ArrayCommands.add,
              "value": buisnessId
            },
            "lastVisitedBuisnessesRemoved": {
              "command": ArrayCommands.remove,
              "value": buisnessId
            },
          }).then((value) {
        if (value) {
          UserData.user.lastVisitedBuisnessesRemoved.remove(buisnessId);
          UserData.user.lastVisitedBuisnesses.add(buisnessId);
        }
      });
    } else {
      await FirestoreClient()
          .updateFieldInsideDocAsArray(
              path: usersCollection,
              docId: UserData.user.phoneNumber,
              fieldName: "lastVisitedBuisnesses",
              value: buisnessId,
              command: ArrayCommands.add)
          .then((value) {
        if (value) {
          UserData.user.lastVisitedBuisnesses.add(buisnessId);
        }
      });
    }
  }

  // --------------------------------- bookings ----------------------------

  Future<bool> addBooking(BuildContext context, Booking booking,
      WorkerModel worker, bool allowedNotification, int minutesBeforeNotify,
      {bool workerAction = false,
      bool addTocalendar = false,
      bool fromUpdate = false}) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.addBooking]);

    if (!UserData.isConnected()) {
      AppErrors.error = Errors.notLogedIn;
      return false;
    }

    if (SettingsData.settings.blockedUsers
        .containsKey(UserData.user.phoneNumber)) {
      AppErrors.error = Errors.blockedUser;
      return false;
    }

    final keyDate = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    final keyTime = DateFormat('HH:mm').format(booking.bookingDate);

    // another user took your booking right before you
    if (worker.bookingsTime.containsKey(keyDate) &&
        worker.bookingsTime[keyDate]!.keys.contains(keyTime)) {
      AppErrors.error = Errors.takenBooking;
      return false;
    }
    booking.copyDataToOrder(
        worker, workerAction, _needToHoldOn(booking, worker));
    final bookingWorkTime = booking.getBookingWorkTimes();
    /*Cancel the worker data and the worker obj listening to not 
      get an update when user order a booking and change the worker 
      public data doc */
    await SettingsData.cancelWorkerListening();
    return await FirestoreClient()
        .addBooking(
            fromWorkerSchedule: workerAction,
            currentUserPhone: UserData.user.phoneNumber,
            booking: booking,
            treatmentDurations: bookingWorkTime,
            workerPhone: worker.phone,
            fromUpdate: fromUpdate,
            clientPhone: booking.customerPhone,
            userLoggedIn: UserData.isConnected())
        .then((value) async {
      if (value) {
        /*create new listener when worker order a booking from the schedule
        page for the first time to this day - need to open listener because 
        there is no one that listen to this day*/

        if (workerAction &&
            UserData.user.phoneNumber == worker.phone &&
            (WorkerData.worker.bookingObjects[keyDate] == null ||
                WorkerData.worker.bookingObjects[keyDate]!.isEmpty)) {
          WorkerData.startListener(date: booking.bookingDate);
        }
        //avoid cases when worker make a booking for client
        if (UserData.user.phoneNumber == booking.customerPhone) {
          // add the booking localy
          UserData.user.bookings[booking.bookingId] = booking;
          /* If user is on the past bookings. after book an order 
            we want him to see the new booking */
          UserData.showCurrentBookings = true;

          NotificationsHelper().setLocalBookingNotification(
              booking, allowedNotification, minutesBeforeNotify);
          if (!fromUpdate) {
            NotificationsHelper().notifyWorkerAboutOrder(worker, booking);
          }
          /*Update the workers locally */
          BookingProvider.addBookingToWorkerLocally(booking);
          // add the order to the calendar
          if (addTocalendar) {
            DeviceCalendar.addEvent(
              key: booking.bookingId,
              decription:
                  translate('bookingTo') + ' ' + SettingsData.settings.shopName,
              location: SettingsData.settings.adress,
              startDate: booking.bookingDate,
              endDate: booking.bookingDate
                  .add(Duration(minutes: booking.treatment.totalMinutes)),
            );
          }

          UiManager.insertUpdate(Providers.user);
          return true;
        }
      }
      return value;
    });
  }

  bool _needToHoldOn(Booking booking, WorkerModel worker) {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.needToHoldOn]);
    final duration =
        DateTime.now().add((Duration(minutes: worker.onHoldMinutes)));
    return duration.isAfter(booking.bookingDate);
  }

  Future<bool> deleteBookingOnlyFromUserDoc(
    BuildContext context,
    Booking booking,
    int minutesBeforeNotify,
  ) async {
    AppErrors.addError(
        code: userCodeToInt[UserErrorCodes.deleteBookingOnlyFromUserDoc]);
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
            path: "$usersCollection/${booking.customerPhone}/$dataCollection",
            docId: dataDoc,
            fieldName: "bookings.${booking.bookingId}")
        .then((value) async {
      if (value) {
        if (UserData.user.phoneNumber == booking.customerPhone) {
          //delete notification
          await NotificationsHelper()
              .deleteLocalBookingNotification(booking, minutesBeforeNotify);
          if (UserData.user.bookings.containsKey(booking.bookingId)) {
            UserData.user.bookings.remove(booking.bookingId);
          }
          if (UserData.user.passedBookings.containsKey(booking.bookingId)) {
            UserData.user.passedBookings.remove(booking.bookingId);
          }
          DeviceCalendar.removeEvent(key: booking.bookingId);
        }
        UiManager.insertUpdate(Providers.user);
      }
      return value;
    });
  }

  Future<bool> deleteBooking(Booking booking, int minutesBeforeNotify,
      {bool deleteCalendar = true, bool fromUpdate = false}) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.deleteBooking]);

    if (!UserData.isConnected()) {
      AppErrors.error = Errors.notLogedIn;
      return false;
    }

    if (!SettingsData.workers.containsKey(booking.workerId)) {
      AppErrors.error = Errors.notFoundItem;
      return false;
    }

    Iterable<DateTime>? freeTime =
        relevantHoures(BookingProvider.workers[booking.workerId], booking) ??
            [];
    bool shouldNotify = (freeTime.length == 0);

    final bookingWorkTime = booking.getBookingWorkTimes();
    return await FirestoreClient()
        .deleteBooking(
            currentUserId: UserData.user.phoneNumber,
            booking: booking,
            treatmentDurations: bookingWorkTime,
            workerId: booking.workerId,
            customerId: booking.customerPhone,
            userLoggedIn: UserData.isConnected())
        .then((value) async {
      if (value) {
        if (!fromUpdate) {
          NotificationsHelper().notifyWorkerDeletedBooking(booking);
          NotificationsHelper().notifyWorkerAboutUserBookingDeletion(booking);
        }
        NotificationsHelper().deleteLocalBookingNotification(
          booking,
          minutesBeforeNotify,
        );

        if (UserData.user.phoneNumber == booking.customerPhone) {
          UserData.user.bookings.remove(booking.bookingId);
          UiManager.insertUpdate(Providers.user);
        }
        BookingProvider.delteBookingFromWorkerLocally(booking);

        logger
            .d("Notify the listeners of waiting list status --> $shouldNotify");
        if (shouldNotify) {
          NotificationsHelper().notifyWaitingListAboutNewTimes(booking);
        }
        if (deleteCalendar) {
          DeviceCalendar.removeEvent(key: booking.bookingId);
        }
      }
      return value;
    });
  }

  Future<bool> updateBooking(
      BuildContext context,
      Booking newBooking,
      Booking oldBooking,
      WorkerModel worker,
      bool allowedNotification,
      int minutesBeforeNotify,
      {bool workerAction = false}) async {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.updateBooking]);

    if (newBooking.isTheSameAs(oldBooking)) {
      logger.i("Dont need to access to database no changes in booking");
      return true;
    }
    // new booking is thebooking provider - save copy to save the object unic
    Booking saveNewBooking = Booking.fromBooking(newBooking);
    saveNewBooking.bookingId = oldBooking.bookingId;
    bool isDeleteSucceed = await this.deleteBooking(
        oldBooking, minutesBeforeNotify,
        deleteCalendar: false, fromUpdate: true);
    bool isAddSucceed = await this.addBooking(context, saveNewBooking, worker,
        allowedNotification, minutesBeforeNotify,
        workerAction: workerAction, addTocalendar: true, fromUpdate: true);
    if (isDeleteSucceed && isAddSucceed) {
      NotificationsHelper()
          .notifyWorkerChangedBooking(oldBooking, saveNewBooking.bookingDate);
      NotificationsHelper().notifyWorkerAboutUserBookingChanging(
          oldBooking, saveNewBooking.bookingDate);
    }
    return isDeleteSucceed && isAddSucceed;
  }

  // ----------------------------- notifications ---------------------------

  bool isAlreadySub({required String topicId, required NotifySorts sort}) {
    AppErrors.addError(code: userCodeToInt[UserErrorCodes.isAlreadySub]);
    if (!UserData.user.subToNotifications.containsKey(sort)) return false;
    if (!UserData.user.subToNotifications.containsKey(sort) ||
        UserData.user.phoneNumber == '') return false;
    return UserData.user.subToNotifications[sort]!.containsKey(topicId);
  }

  // ---------------------------- user details ------------------------------

  Future<bool> addOrRemoveLikeForStoryImage(String imageId, String workerPhone,
      String userPhoneThatLiked, ArrayCommands command) async {
    AppErrors.addError(
        code: userCodeToInt[UserErrorCodes.addOrRemoveLikeForStoryImage]);
    return await FirestoreClient()
        .updateFieldInsideDocAsArray(
            path: usersCollection,
            docId: userPhoneThatLiked,
            fieldName: "storyLikes",
            value: imageId,
            command: command)
        .then((value) {
      if (value) {
        int currentLikes =
            SettingsData.workers[workerPhone]!.storylikesAmount[imageId] ?? 0;
        if (command == ArrayCommands.add) {
          FirebaseRealTimeClient().updateNumberChild(
              pathToChild: DbPathesHelper().getLisksChildPath(workerPhone),
              valueId: imageId,
              delta: 1,
              command: NumericCommands.increment);
          UserData.user.storyLikes.add(imageId);
          SettingsData.workers[workerPhone]!.storylikesAmount[imageId] =
              currentLikes + 1;
        } else {
          if (currentLikes >= 0) {
            FirebaseRealTimeClient().updateNumberChild(
                pathToChild: DbPathesHelper().getLisksChildPath(workerPhone),
                valueId: imageId,
                delta: 1,
                command: NumericCommands.decrement);
            SettingsData.workers[workerPhone]!.storylikesAmount[imageId] = max(
                SettingsData.workers[workerPhone]!.storylikesAmount[imageId]! -
                    1,
                0);
          }

          UserData.user.storyLikes.remove(imageId);
        }
      }
      return value;
    });
  }

  void updateScreen() => notifyListeners();
}
