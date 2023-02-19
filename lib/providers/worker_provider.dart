import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/services/clients/firebase_storage_client.dart';
import 'package:simple_tor_web/services/clients/firestore_client.dart';
import 'package:simple_tor_web/services/clients/server_notifications_client.dart';
import 'package:simple_tor_web/models/treatment_model.dart';
import 'package:simple_tor_web/services/errors_service/app_errors.dart';
import 'package:simple_tor_web/services/errors_service/worker.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:simple_tor_web/utlis/times_utlis.dart';
import 'package:uuid/uuid.dart';

import '../app_const/booking.dart';
import '../app_const/db.dart';
import '../app_const/limitations.dart';
import '../app_const/purchases.dart';
import '../app_statics.dart/general_data.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/worker_data.dart';
import '../models/booking_model.dart';
import '../ui/general_widgets/custom_widgets/custom_toast.dart';

class WorkerProvider extends ChangeNotifier {
  Future<void> setUpWorker(
      {required String userPhone, required BuildContext context}) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.setUpWorker]);

    if (SettingsData.workers.containsKey(userPhone)) {
      /*Take the worker obj from settings no need to 
        read the worker from the db again*/
      WorkerData.worker = SettingsData.workers[userPhone]!;
      WorkerData.updateOnHoldMinutesIfNeeded();
      WorkerData.updateOnHoldMinutesIfNeeded();
      _updateNotifyOnWaitingListEventsIfNeeded();
      _deleteBookingsOfDayBefore();
      _cleanExpiredData();
    }
  }

  Future<void> _updateNotifyOnWaitingListEventsIfNeeded() async {
    AppErrors.addError(
        code: workerCodeToInt[
            WorkerErrorCodes.updateNotifyOnWaitingListEventsIfNeeded]);
    if (SettingsData.businessSubtype == SubType.basic &&
        WorkerData.worker.notifyOnWaitingListEvents == true) {
      await FirestoreClient()
          .updateFieldInsideDocAsMap(
              path:
                  "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
              docId: WorkerData.worker.phone,
              fieldName: "notifyOnWaitingListEvents",
              value: false)
          .then((value) {
        if (value) {
          WorkerData.worker.notifyOnWaitingListEvents = false;
          logger.d("Update worker notifyOnWaitingListEvents successfully");
        }
        return value;
      });
    }
  }

  Future<void> _deleteBookingsOfDayBefore() async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.deleteBookingsOfDayBefore]);
    if (WorkerData.worker.saveData ||
        WorkerData.worker.lastDeleteBookingsDataDay == "") return;

    final today = setToMidNight(DateTime.now());
    DateTime lastCleanDate = DateFormat('dd-MM-yyyy')
        .parse(WorkerData.worker.lastDeleteBookingsDataDay);

    /*Its possible that the worker not enter to the app few days so its
      must to clean all the days before and not only yesterday */
    while (lastCleanDate.isBefore(today)) {
      try {
        await FirestoreClient().deleteDoc(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection/${WorkerData.worker.phone}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
            docId: DateFormat('dd-MM-yyyy').format(lastCleanDate));
      } catch (e) {
        logger.e("Faild to delete yesterday bookings --> $e");
      }
      lastCleanDate = lastCleanDate.add(Duration(days: 1));
    }

    /* If need to update the worker field - its happen when the while
      loop before happened atlist once */
    if (DateFormat('dd-MM-yyyy').format(lastCleanDate) !=
        WorkerData.worker.lastDeleteBookingsDataDay) {
      await FirestoreClient().updateFieldInsideDocAsMap(
          path:
              "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
          docId: WorkerData.worker.phone,
          fieldName: "lastDeleteBookingsDataDay",
          value: DateFormat('dd-MM-yyyy').format(lastCleanDate));
    }
  }

  // Future<void> _updateDurationToCleanExpiredIfNeeded() async {
  //   AppErrors.addError(
  //       code: workerCodeToInt[
  //           WorkerErrorCodes.updateDurationToCleanExpiredIfNeeded]);
  //   if (WorkerData.worker.durationToCleanExpired.inDays <=
  //       SettingsData.settings
  //           .limits[BuisnessLimitations.expiredDataDeleteHeighsetDays]!) return;
  //  await Client()
  //       .updateFieldInsideDocAsMap(
  //           path:
  //               "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
  //           docId: WorkerData.worker.phone,
  //           fieldName: "daysToCleanExpired",
  //           value: SettingsData.settings
  //               .limits[BuisnessLimitations.expiredDataDeleteHeighsetDays]!)
  //       .then((value) {
  //     if (value) {
  //       WorkerData.worker.durationToCleanExpired = Duration(
  //           days: SettingsData.settings
  //               .limits[BuisnessLimitations.expiredDataDeleteHeighsetDays]!);
  //       logger.d("Worker new expired data delete days succesfully updated!");
  //     }
  //   });
  // }

  void updateNotifyWhenGettingBooking(bool update) {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.updateNotifyWhenGettingBooking]);
    // don't need to update the server
    if (update == WorkerData.worker.notifyWhenGettingBooking) return;
    // first - changing to prevent ui delay
    WorkerData.worker.notifyWhenGettingBooking = update;
    UiManager.insertUpdate(Providers.worker);
    // sending requst
    FirestoreClient()
        .updateFieldInsideDocAsMap(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: WorkerData.worker.phone,
            fieldName: "notifyWhenGettingBooking",
            value: update)
        .then((resp) {
      if (resp) {
        // succes - nothing to do - already changed
        logger.d("Worker new notifyWhenGettingBooking status -> $update");
      } else {
        // failed  - return the state to before (user see after re-build)
        WorkerData.worker.notifyWhenGettingBooking = !update;
        //UiManager.insertUpdate(Providers.worker);
      }
      return resp;
    });
  }

  void updateNotifyOnWaitingListEvents(bool update) {
    AppErrors.addError(
        code:
            workerCodeToInt[WorkerErrorCodes.updateNotifyOnWaitingListEvents]);
    // don't need to update the server
    if (update == WorkerData.worker.notifyOnWaitingListEvents) return;
    // first - changing to prevent ui delay
    WorkerData.worker.notifyOnWaitingListEvents = update;
    UiManager.insertUpdate(Providers.worker);
    // sending requst
    FirestoreClient()
        .updateFieldInsideDocAsMap(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: WorkerData.worker.phone,
            fieldName: "notifyOnWaitingListEvents",
            value: update)
        .then((resp) {
      if (resp) {
        // succes - nothing to do - already changed
        logger.d("Worker new notifyOnWaitingListEvents status -> $update");
      } else {
        // failed  - return the state to before (user see after re-build)
        WorkerData.worker.notifyOnWaitingListEvents = !update;
        //UiManager.insertUpdate(Providers.worker);
      }
      return resp;
    });
  }

  // Future<bool> deleteUserBooking(Booking booking){

  // }

  void setDeleteWorkerData(bool update) {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.updateNotifyWhenGettingBooking]);
    // don't need to update the server
    if (update == WorkerData.worker.saveData) return;
    // first - changing to prevent ui delay
    WorkerData.worker.saveData = update;
    UiManager.insertUpdate(Providers.worker);
    // sending requstff
    final todayString = DateFormat('dd-MM-yyyy').format(DateTime.now());
    FirestoreClient().updateMultipleFieldsInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: WorkerData.worker.phone,
      data: {"saveData": update, "lastDeleteBookingsDataDay": todayString},
    ).then((resp) async {
      if (!resp) {
        // failed  - return the state to before (user see after re-build)
        WorkerData.worker.notifyWhenGettingBooking = !update;
      }
      return resp;
    });
  }

  void updateAllowNotLoggedInToOrder(bool update) {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.updateAllowNotLoggedInToOrder]);
    // don't need to update the server
    if (update == WorkerData.worker.allowNotLoggedInBookings) return;
    // first - changing to prevent ui delay
    WorkerData.worker.allowNotLoggedInBookings = update;
    UiManager.insertUpdate(Providers.worker);
    // sending requst
    FirestoreClient()
        .updateFieldInsideDocAsMap(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: WorkerData.worker.phone,
            fieldName: "allowNotLoggedInBookings",
            value: update)
        .then((resp) {
      if (resp) {
        // succes - nothing to do - already changed
        logger.d("Worker new allowNotLoggedInBookings status -> $update");
      } else {
        // failed  - return the state to before (user see after re-build)
        WorkerData.worker.allowNotLoggedInBookings = !update;
        //UiManager.insertUpdate(Providers.worker);
      }
      return resp;
    });
  }

  // ------------------------ expired ------------------------------

  Future<void> _cleanExpiredData() async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.cleanExpiredData]);
    if (WorkerData.worker.phone == '') return;

    DateTime lastClean = WorkerData.worker.lastCleanDate.toDate();

    logger.i("Last worker clean is --> $lastClean");
    if (lastClean
        .add(durationToCleanWorkerExpiredData)
        .isAfter(DateTime.now())) {
      /*No need to clean worker is already up to date */
      return;
    }

    logger.d("Start to update the worker & bookings");
    //update the last clean date
    WorkerData.worker.lastCleanDate = Timestamp.fromDate(DateTime.now());
    //The data is updated to this date by the WorkerMoudel from.json function not need to check again
    await FirestoreClient()
        .setDoc(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: WorkerData.worker.phone,
      valueAsJson: WorkerData.worker.toWorkerDocJson(),
    )
        .then(
      (value) async {
        if (value) {
          //clean public data doc
          return await FirestoreClient().setDoc(
              path:
                  "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection/${WorkerData.worker.phone}/$dataCollection",
              docId: dataDoc,
              valueAsJson: WorkerData.worker.toWorkerPublicDataJson());
        }
        return value;
      },
    );
  }

  //---------------------------- worker image ----------------------

  Future<void> updateWokerImage(BuildContext context, XFile? image) async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.updateWokerImage]);
    String collection =
        "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection";
    if (image != null) {
      if (WorkerData.worker.profileImg == "") {
        await FirebaseStorageClient()
            .uploadImage(
                image: image,
                imageType: "profileImg",
                storagePath: profilePhotosPath,
                dbCollection: collection,
                dbDoc: WorkerData.worker.phone)
            .then((path) {
          WorkerData.worker.profileImg = path;
          UiManager.insertUpdate(Providers.worker);
        });
      }
      await FirebaseStorageClient()
          .updateImage(
              image: image,
              imageType: "profileImg",
              currentUrl: WorkerData.worker.profileImg,
              storagePath: profilePhotosPath)
          .then((path) async {
        await SettingsData.businessCacheManager
            .removeFile(WorkerData.worker.profileImg);
        WorkerData.worker.profileImg = path;
        await SettingsData.businessCacheManager
            .downloadFile(WorkerData.worker.profileImg);
        UiManager.insertUpdate(Providers.worker);
      });
    }
  }

  Future<bool> deleteWorkerImage() async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.deleteWorkerImage]);
    if (WorkerData.worker.profileImg == '') true;
    return await FirebaseStorageClient()
        .deleteImage(
            userPhone: WorkerData.worker.phone,
            imageUrl: WorkerData.worker.profileImg,
            imageType: "profileImg",
            dbDocId: WorkerData.worker.phone,
            dbPath:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            storagePath: profilePhotosPath,
            dbFieldName: "profileImg",
            dbValue: '',
            inArray: false)
        .then((resp) {
      if (resp) {
        WorkerData.worker.profileImg = '';
        UiManager.insertUpdate(Providers.worker);
      }
      return resp;
    });
  }

  //------------------------- worker details -----------------------

  void removeTimeFromDay(String start, String end, String day) {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.removeTimeFromDay]);
    WorkerData.worker.workTime[day]!.remove(start);
    WorkerData.worker.workTime[day]!.remove(end);
    UiManager.insertUpdate(Providers.worker);
  }

  void addTimeToDay(String start, String end, String day) {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.addTimeToDay]);
    WorkerData.worker.workTime[day]!.add(start);
    WorkerData.worker.workTime[day]!.add(end);
    UiManager.insertUpdate(Providers.worker);
  }

  Future<bool> addOrUpdateTreatment(
      Map<String, dynamic> treatment, String treatmentId, BuildContext context,
      {Treatment? oldTreatment}) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.addTreatment]);
    treatmentId = treatmentId == "" ? Uuid().v1() : treatmentId;

    if (oldTreatment != null) {
      if (treatmentId != oldTreatment.name) {
        // id changing (treatment name) -> delete the old one and add the new one
        await this.removeTreatment(oldTreatment, oldTreatment.name);
        if (WorkerData.worker.treatments.keys.contains(treatmentId)) {
          // if removal failed stop
          return false;
        }
      }

      final oldTreatmentJson = oldTreatment.toJson();
      /* put the name in the treatments maps for 
        compare the names also*/

      oldTreatmentJson["name"] = oldTreatment.name;
      treatment["name"] = treatmentId;
      if (const DeepCollectionEquality().equals(treatment, oldTreatmentJson)) {
        // no need to update db
        CustomToast(context: context, msg: translate("sameData")).init();
        logger.d("Nothing changes - no need to update");
        return false;
      }
    }

    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: WorkerData.worker.phone,
      fieldName: "treatments.$treatmentId",
      value: treatment,
    )
        .then((resp) {
      if (resp) {
        if (SettingsData.workers.containsKey(WorkerData.worker.phone)) {
          SettingsData
                  .workers[WorkerData.worker.phone]!.treatments[treatmentId] =
              Treatment.fromJson(treatment, treatmentId);
        }
        WorkerData.worker.treatments[treatmentId] =
            Treatment.fromJson(treatment, treatmentId);
        UiManager.insertUpdate(Providers.worker);
      }
      return resp;
    });
  }

  Future<void> removeTreatment(Treatment treatment, String treatmentId) async {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.removeTreatment]);
    await FirestoreClient()
        .updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: WorkerData.worker.phone,
      fieldName: "treatments.$treatmentId",
    )
        .then((resp) {
      if (resp) {
        if (SettingsData.workers.containsKey(WorkerData.worker.phone)) {
          SettingsData.workers[WorkerData.worker.phone]!.treatments
              .remove(treatmentId);
        }
        WorkerData.worker.treatments.remove(treatmentId);
        UiManager.insertUpdate(Providers.worker);
      }
    });
  }

  Future<void> changeOnHoldMinutes(int minutes, BuildContext context) async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.changeOnHoldMinutes]);
    WorkerData.worker.onHoldMinutes = minutes;
    UiManager.insertUpdate(Providers.worker);
    UiManager.updateUi(context: context);
    await FirestoreClient().updateFieldInsideDocAsMap(
      path:
          "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
      docId: WorkerData.worker.phone,
      fieldName: "onHoldMinutes",
      value: minutes,
    );
  }

  void setVacations(Map<String, List<String>> vacations) {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.setFocusedDate]);
    WorkerData.worker.vacations = vacations;
  }

  void setWorkTime(Map<String, List<String>> workTime) {
    AppErrors.addError(code: workerCodeToInt[WorkerErrorCodes.setWorkTime]);
    WorkerData.worker.workTime = workTime;
  }

  Future<bool> cahngeStatusForBooking(Booking booking, BuildContext context,
      BookingStatuses status, Map<String, Booking> userBookings) async {
    AppErrors.addError(
        code: workerCodeToInt[WorkerErrorCodes.cahngeStatusForBooking]);
    if (booking.status == status) return true;
    final dateKey = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection/${booking.workerId}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
            docId: dateKey,
            fieldName: "${booking.bookingId}.status",
            value: bookingsMassage[status])
        .then((value) async {
      return await FirestoreClient()
          .updateFieldInsideDocAsMap(
              // path: booking.anonymousDocId == ''
              //     ? usersCollection
              //     : anonymousCollection,
              // docId: booking.anonymousDocId == ''
              //     ? booking.customerPhone
              //     : booking.anonymousDocId,
              path: "$usersCollection/${booking.customerPhone}/$dataCollection",
              docId: dataDoc,
              fieldName: "bookings.${booking.bookingId}.status",
              value: bookingsMassage[status])
          .then((value) {
        if (value &&
            status == BookingStatuses.approved &&
            booking.deviceFCM.length > 10)
          ServerNotificationsClient().notifyApprovedBooking(
              userFCM: booking.deviceFCM,
              msg: translate("hey") +
                  " " +
                  booking.customerName +
                  " " +
                  translate("yourBooking") +
                  " " +
                  translate("to2") +
                  booking.workerName +
                  " " +
                  translate("confirm"),
              title: translate("confirmed"));
        if (value && booking.workerId == booking.customerPhone)
          userBookings[booking.bookingId]!.status = BookingStatuses.approved;
        return value;
      });
    });
  }

  void updateScreen() => notifyListeners();
}
