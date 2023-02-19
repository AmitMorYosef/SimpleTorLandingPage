import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/app_const/business_types.dart';
import 'package:management_system_app/models/preview_model.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/services/clients/firestore_client.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/services/errors_service/manager.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';

import '../app_const/db.dart';
import '../app_const/display.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/user_data.dart';
import '../models/currency_model.dart';
import '../models/notification_topic.dart';
import '../services/clients/server_notifications_client.dart';
import '../services/errors_service/messages.dart';

class ManagerProvider extends ChangeNotifier {
  Future<bool> makeUserToWorker(
      String phoneNumber, BuildContext context) async {
    AppErrors.addError(
        code: managerCodeToInt[ManagerErrorCodes.makeUserToWorker]);
    if (SettingsData.eligibleWorkerAmount <= SettingsData.workers.length - 1) {
      AppErrors.error = Errors.passedLimit;
      return false;
    }
    if (SettingsData.workers.containsKey(phoneNumber)) {
      //worker already in the data base
      AppErrors.error = Errors.alreadyWorker;
      return false;
    }

    final snapshot = await FirestoreClient().getDoc(
        path: "$usersCollection/$phoneNumber/$dataCollection", docId: dataDoc);

    if (!snapshot.exists) {
      AppErrors.error = Errors.notFoundItem;
      return false;
    }
    final worker = WorkerModel.fromUserPublicData(snapshot.data()!);
    return await FirestoreClient()
        .userToWorker(
            userPhone: phoneNumber,
            valueAsJson: worker.toWorkerDocJson(),
            buisnessId: SettingsData.appCollection)
        .then((value) {
      if (value) {
        UiManager.updateUi(
            context: context,
            perform: Future((() => context
                .read<SettingsProvider>()
                .addWorker(phoneNumber, worker.name))));
      }
      return value;
    });
  }

  Future<bool> deleteWorker(
      String phoneNumber, String buisnessId, BuildContext context,
      {bool insideLoop = false}) async {
    AppErrors.addError(code: managerCodeToInt[ManagerErrorCodes.deleteWorker]);
    return await FirestoreClient()
        .deleteWorker(
      workerPhone: phoneNumber,
      buisnessId: buisnessId,
    )
        .then((value) {
      if (value) {
        SettingsData.removeWorker(phoneNumber);
        UiManager.insertUpdate(Providers.settings);
      }
      return value;
    });
  }

  Future<String> createBuisness(
      {required BuildContext context,
      required String businessName,
      required String adress,
      required String productId,
      required String instagram,
      required BusinessesTypes businessType,
      required String revenueCatId,
      required CurrencyModel currency,
      required Themes theme}) async {
    AppErrors.addError(
        code: managerCodeToInt[ManagerErrorCodes.createBuisness]);
    final isManager = UserData.isDevloper();
    Preview preview = await FirestoreClient()
        .createBuissness(
            user: UserData.user,
            revenueCatId: revenueCatId,
            productId: productId,
            businessType: businessType,
            shopName: businessName,
            adress: adress,
            instagramAccount: instagram,
            isManager: isManager,
            currency: currency,
            theme: theme)
        .then((preview) {
      if (preview.buisnessId != '') {
        if (!isManager) {
          /*add only to regular users */
          UserData.user.previews[preview.buisnessId] = preview;
        }
        /*Add locally to previews but not to the db .
          add to db -  managers and for published businesses */
        SettingsData.addPreviewBuisness(preview);
        if (!UserData.user.myBuisnessesIds.contains(preview.buisnessId)) {
          UserData.user.myBuisnessesIds.add(preview.buisnessId);
        }
        UserData.user.permission[preview.buisnessId] = 2;
      }
      return preview;
    });

    return preview.buisnessId;
  }

  Future<bool> deleteBuisness(String businessId, String revenueCatId,
      String productId, String workerProductId) async {
    AppErrors.addError(
        code: managerCodeToInt[ManagerErrorCodes.deleteBuisness]);

    return await FirestoreClient()
        .deleteBuissness(
            revenueCatId: revenueCatId,
            user: UserData.user,
            isExistInPreviews: !UserData.user.previews.containsKey(businessId),
            productId: productId,
            workerProductId: workerProductId,
            businessId: businessId)
        .then((value) async {
      if (value) {
        logger.d("Finish delete buisness --> ${businessId}");
        if (productId != "") {
          UserData.user.productsIds[productId] = {
            "date": Timestamp.fromDate(DateTime.now()),
            "businessId": ""
          };
        }
        if (workerProductId != "") {
          UserData.user.productsIds[workerProductId] = {
            "date": Timestamp.fromDate(DateTime.now()),
            "businessId": ""
          };
        }

        if (UserData.user.previews.containsKey(businessId)) {
          UserData.user.previews.remove(businessId);
        }
        SettingsData.removePreviewBuisness(businessId);
        UserData.user.permission.remove(businessId);
        UserData.user.myBuisnessesIds.remove(businessId);
        if (businessId == SettingsData.appCollection) {
          await SettingsData.emptyBusinessData();
        }
      }
      return value;
    });
  }

  Future<bool> sendGeneralNotification(
      {required String buisnessId,
      required String msg,
      required String title}) async {
    AppErrors.addError(
        code: managerCodeToInt[ManagerErrorCodes.sendGeneralNotification]);
    return await ServerNotificationsClient()
        .notifyGeneralNotification(
            topic: NotificationTopic(businessId: buisnessId).toTopicStr(),
            msg: msg,
            title: title)
        .then((value) {
      if (!value) AppErrors.error = Errors.unknown;
      return value;
    });
  }

  static Future<bool> purchaseSubAfterExpiration(
      {required String businessId,
      required String productId,
      required String revenueCatId,
      bool isBusinessPurchase = true}) async {
    AppErrors.addError(
        code: managerCodeToInt[ManagerErrorCodes.purchaseSubAfterExpiration]);
    final isExistInPreviews = !UserData.user.previews.containsKey(businessId);
    return await FirestoreClient()
        .purchaseSubAfterExpiration(
            isExistInPreviews: isExistInPreviews,
            businessId: businessId,
            productId: productId,
            preview: !isExistInPreviews &&
                    isBusinessPurchase &&
                    UserData.user.previews.containsKey(businessId)
                ? UserData.user.previews[businessId]!
                : null,
            userPhone: UserData.user.phoneNumber,
            revenueCatId: revenueCatId,
            isBusinessPurchase: isBusinessPurchase)
        .then((value) {
      if (value) {
        SettingsData.settings.productId = productId;
        UserData.user.productsIds[productId] = {
          "date": Timestamp.fromDate(DateTime.now()),
          "businessId": businessId
        };
        if (!isExistInPreviews &&
            isBusinessPurchase &&
            UserData.user.previews.containsKey(businessId)) {
          SettingsData.addPreviewBuisness(UserData.user.previews[businessId]!);
          UserData.user.previews.remove(businessId);
        }
      }
      return value;
    });
  }

  static Future<bool> changeSub(
      {required String buisnessId,
      required String productId,
      bool isBusinessPurchase = true}) async {
    /*put the sub details in user doc and business doc.
      isBusinessPurchase = determind if the sub is worker
       or businessSubType*/
    AppErrors.addError(code: managerCodeToInt[ManagerErrorCodes.changeSub]);
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
      path: buisnessCollection,
      docId: buisnessId,
      fieldName:
          isBusinessPurchase ? "pendingProductId" : "pendingWorkersProductsId",
      value: productId,
    )
        .then((value) async {
      if (value) {
        isBusinessPurchase
            ? SettingsData.settings.pendingProductId = productId
            : SettingsData.settings.pendingWorkersProductsId = productId;
      }
      return value;
    });
  }

  static Future<bool> removeBlock({required String userId}) async {
    if (UserData.getPermission() < 2) {
      AppErrors.error = Errors.noPermission;
      return false;
    }
    if (SettingsData.appCollection == "") {
      AppErrors.error = Errors.unknown;
      return false;
    }
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
      path: buisnessCollection,
      docId: SettingsData.appCollection,
      fieldName: "blockedUsers.$userId",
    )
        .then((value) async {
      if (value) {
        if (SettingsData.settings.blockedUsers.containsKey(userId)) {
          SettingsData.settings.blockedUsers.remove(userId);
        }
        UiManager.insertUpdate(Providers.settings);
      }
      return value;
    });
  }

  static Future<bool> blockUser(
      {required String userId, String? gender, String? name}) async {
    if (UserData.getPermission() < 2) {
      AppErrors.error = Errors.noPermission;
      return false;
    }
    if (SettingsData.appCollection == "") {
      AppErrors.error = Errors.unknown;
      return false;
    }
    if (gender == null || name == null) {
      await FirestoreClient()
          .getDoc(
              path: "$usersCollection/$userId/$dataCollection", docId: dataDoc)
          .then((snapshot) {
        if (snapshot.exists) {
          name = snapshot["name"] ?? "";
          gender = snapshot["gender"] ?? "";
        }
      });
    }
    if (name == null && gender == null) {
      AppErrors.error = Errors.userNotFound;
      return false;
    }

    final todayString = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final detailsString = "$todayString~$gender~$name";

    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
      path: buisnessCollection,
      docId: SettingsData.appCollection,
      fieldName: "blockedUsers.$userId",
      value: detailsString,
    )
        .then((value) async {
      if (value) {
        SettingsData.settings.blockedUsers[userId] = detailsString;
        UiManager.insertUpdate(Providers.settings);
      }
      return value;
    });
  }

  void updateScreen() => notifyListeners();
}
