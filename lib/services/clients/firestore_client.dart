import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app_const/application_general.dart';
import '../../app_const/business_types.dart';
import '../../app_const/db.dart';
import '../../app_const/display.dart';
import '../../app_const/worker_scedule.dart';
import '../../app_statics.dart/general_data.dart';
import '../../app_statics.dart/settings_data.dart';
import '../../models/booking_model.dart';
import '../../models/break_model.dart';
import '../../models/currency_model.dart';
import '../../models/general_settings_model.dart';
import '../../models/preview_model.dart';
import '../../models/user_model.dart';
import '../../models/worker_model.dart';
import '../../providers/helpers/db_pathes_helper.dart';
import '../../providers/helpers/notifications_helper.dart';
import '../../utlis/times_utlis.dart';
import '../errors_service/app_errors.dart';
import '../errors_service/messages.dart';
import '../external_services/firebase_notifications.dart';
import '../external_services/firebase_storage.dart';
import '../external_services/firestore.dart';
import '../external_services/real_time_database.dart';

class FirestoreClient {
  static final FirestoreClient _singleton = FirestoreClient._internal();

  FirestoreClient._internal();

  factory FirestoreClient() {
    FirestoreClient object = _singleton;
    return object;
  }

  final FirestoreDataBase firestoreDataBase = FirestoreDataBase();
  final StorageDb firebaseStorage = StorageDb();
  final RealTimeDatabase realTimeDatabase = RealTimeDatabase();
  final FirebaseNotifications _notifications = FirebaseNotifications();
  Uuid uuid = const Uuid();

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
      {required String path,
      required String docId,
      bool insideEnviroments = true}) async {
    return await firestoreDataBase.getDoc(
        path: path, docId: docId, insideEnviroments: insideEnviroments);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocsWithQueries(
      {required String path,
      required Map<String, Map<QueryCommands, dynamic>> queryMap,
      bool insideEnviroments = true}) async {
    return await firestoreDataBase.getDocsWithQueries(
      path: path,
      queryMap: queryMap,
      insideEnviroments: insideEnviroments,
    );
  }

  Future<bool> createDoc(
      {required String path,
      required String docId,
      required valueAsJson,
      bool insideEnviroments = true}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.createDoc(
        batch: batch,
        path: path,
        docId: docId,
        valueAsJson: valueAsJson,
        insideEnviroments: insideEnviroments);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> updateFieldInsideDocAsArray(
      {required String path,
      required String docId,
      required String fieldName,
      required dynamic value,
      required ArrayCommands command}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateFieldInsideDocAsArray(
        batch: batch,
        path: path,
        docId: docId,
        fieldName: fieldName,
        value: value,
        command: command);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> updateMultipleFieldsInsideDocAsArray({
    required String path,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateMultipleFieldsInsideDocAsArray(
        batch: batch, path: path, docId: docId, data: data);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> updateFieldInsideDocAsMap(
      {required String path,
      required String docId,
      required String fieldName,
      dynamic value,
      bool insideEnviroments = true,
      NumericCommands? command = null}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateFieldInsideDocAsMap(
        insideEnviroments: insideEnviroments,
        batch: batch,
        path: path,
        docId: docId,
        fieldName: fieldName,
        value: value,
        command: command);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> updateMultipleFieldsInsideDocAsMap({
    required String path,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateMultipleFieldsInsideDocAsMap(
        batch: batch, path: path, docId: docId, data: data);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> deleteDoc({required String path, required String docId}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.deleteDoc(batch: batch, path: path, docId: docId);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> setDoc(
      {required String path,
      required String docId,
      required dynamic valueAsJson,
      bool insideEnviroments = true}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.setDoc(
        batch: batch,
        path: path,
        docId: docId,
        valueToSet: valueAsJson,
        insideEnviroments: insideEnviroments);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> docListener(
      {required String path, required String docId}) {
    return firestoreDataBase.docListener(
      path: path,
      docId: docId,
    );
  }

  Future<List<String>> getAllDocIdsInsideCollection(
      {required String path}) async {
    return await firestoreDataBase.getAllDocIdsInsideCollection(path: path);
  }

  Future<List<Map<String, dynamic>>?> getAllDocInsideCollection(
      {required String path}) async {
    return await firestoreDataBase.getAllDocsInsideCollection(path: path);
  }

//--------------------  user -------------------------

  Future<bool> updatePublicUserField(
      {required String userPhone,
      required List<String> businessesIds,
      required String fieldName,
      required dynamic value}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: usersCollection,
        docId: userPhone,
        fieldName: fieldName,
        value: value);

    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: "$usersCollection/$userPhone/$dataCollection",
        docId: dataDoc,
        fieldName: fieldName,
        value: value);

    businessesIds.forEach((businessId) {
      firestoreDataBase.updateFieldInsideDocAsMap(
          batch: batch,
          path: "$buisnessCollection/$businessId/$workersCollection",
          docId: userPhone,
          fieldName: fieldName,
          value: value);
    });
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

//---------------------buisness---------------------------

  Future<bool> updateFieldInsideBusinessAndPreview(
      {required String previewsFieldName,
      required bool isExistInPreviews,
      required String userPhone,
      required String businessDocFieldName,
      required String businessId,
      required dynamic value}) async {
    final batch = firestoreDataBase.batch;

    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: buisnessCollection,
        docId: businessId,
        fieldName: businessDocFieldName,
        value: value);

    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: isExistInPreviews ? buisnessesPreviewCollection : usersCollection,
        docId: isExistInPreviews ? previewDoc : userPhone,
        fieldName: isExistInPreviews
            ? 'businesses.$businessId.$previewsFieldName'
            : 'previews.$businessId.$previewsFieldName',
        value: value);

    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> purchaseSubAfterExpiration({
    required String businessId,
    required String productId,
    required String userPhone,
    required bool isExistInPreviews,
    required String revenueCatId,
    required bool isBusinessPurchase,
    Preview? preview,
  }) async {
    /*put the sub details in user doc and business doc.
      isBusinessPurchase = determind if the sub is worker or businessSubType*/
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateFieldInsideDocAsMap(
      batch: batch,
      path: buisnessCollection,
      docId: businessId,
      fieldName: isBusinessPurchase ? "productId" : "workersProductsId",
      value: productId,
    );

    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: usersCollection,
        docId: userPhone,
        fieldName: "productsIds.${productId}",
        value: {
          "date": Timestamp.fromDate(DateTime.now()),
          "businessId": businessId
        });

    /*pass the preview from the user to the previews collection */
    if (!isExistInPreviews && isBusinessPurchase && preview != null) {
      firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: usersCollection,
        docId: userPhone,
        fieldName: "previews.$businessId",
      );
      firestoreDataBase.updateMultipleFieldsInsideDocAsMap(
          batch: batch,
          path: buisnessesPreviewCollection,
          docId: previewDoc,
          data: {
            "amount": NumericCommands.increment,
            "businesses.$businessId": preview.toJson()
          });
    }

    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<Preview> createBuissness(
      {required User user,
      required String instagramAccount,
      required String shopName,
      required String productId,
      required String adress,
      required Themes theme,
      required BusinessesTypes businessType,
      required CurrencyModel currency,
      required String revenueCatId,
      bool isManager = false}) async {
    final batch = firestoreDataBase.batch;
    GeneralSettingsModel settingsModel = GeneralSettingsModel(
        shopPhone: user.phoneNumber,
        shopName: shopName,
        productId: productId,
        currency: currency,
        revenueCatId: revenueCatId,
        ownersName: user.name,
        adress: adress,
        businesseType: businessType,
        instagramAccount: instagramAccount,
        theme: theme);
    WorkerModel worker = WorkerModel(
        phone: user.phoneNumber,
        name: user.name,
        currentFcm: user.currentFcm,
        gender: user.gender);
    //add to the buisness preview
    Preview preview = Preview(
        address: settingsModel.adress,
        businesseType: businessType,
        buisnessId: "${user.phoneNumber.replaceAll("+", "")}--${uuid.v1()}",
        imageUrl: settingsModel.shopIconUrl,
        name: settingsModel.shopName);

    // firestoreDataBase.updateFieldInsideDocAsMap(
    //     batch: batch,
    //     path: usersCollection,
    //     docId: user.phoneNumber,
    //     fieldName: "productsIds.${productId}",
    //     value: {"businessId": preview.buisnessId, "date": Timestamp.now()});

    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: "$usersCollection/${user.phoneNumber}/$dataCollection",
        docId: dataDoc,
        fieldName: "permission.${preview.buisnessId}",
        value: 2);

    firestoreDataBase.setDoc(
        batch: batch,
        path: "$buisnessCollection/${preview.buisnessId}/$workersCollection",
        docId: user.phoneNumber,
        valueToSet: worker.toWorkerDocJson());

    firestoreDataBase.setDoc(
        batch: batch,
        path:
            "$buisnessCollection/${preview.buisnessId}/$workersCollection/${user.phoneNumber}/$dataCollection",
        docId: dataDoc,
        valueToSet: {"bookingsTimes": {}});

    firestoreDataBase.setDoc(
        batch: batch,
        path: buisnessCollection,
        docId: preview.buisnessId,
        valueToSet: settingsModel.toJson());

    if (!isManager) {
      firestoreDataBase.updateFieldInsideDocAsMap(
          batch: batch,
          path: usersCollection,
          docId: user.phoneNumber,
          fieldName: "previews.${preview.buisnessId}",
          value: preview.toJson());
    }

    if (isManager) {
      firestoreDataBase.updateMultipleFieldsInsideDocAsMap(
          batch: batch,
          path: buisnessesPreviewCollection,
          docId: previewDoc,
          data: {
            "amount": NumericCommands.increment,
            "businesses.${preview.buisnessId}": preview.toJson()
          });
    }

    return await firestoreDataBase.commmitBatch(batch: batch).then((value) {
      if (value) {
        logger.i("Finish build buisnesss ");
        return preview;
      } else {
        logger.e("Building buisnesss doesnt successed");
        return Preview();
      }
    });
  }

  Future<bool> deleteBuissness(
      {required User user,
      required String businessId,
      required String revenueCatId,
      required bool isExistInPreviews,
      required String workerProductId,
      required String productId}) async {
    final batch = firestoreDataBase.batch;
    String path = "$buisnessCollection/${businessId}";
    final workersPath = "$path/$workersCollection";
    List<String> workersIds = [];
    Map<String, List<String>> bookingsObjectsDocs = {};
    //get all workers ids

    if (businessId == GeneralData.currentBusinesssId) {
      workersIds = SettingsData.workers.keys.toList();
    } else {
      workersIds = await getAllDocIdsInsideCollection(
          path: "$buisnessCollection/${businessId}/$workersCollection");
    }

    await Future.forEach(workersIds, (workerId) async {
      final docsIds = await getAllDocIdsInsideCollection(
          path:
              "$workersPath/$workerId/$dataCollection/$dataDoc/$bookingsObjectsCollection");
      bookingsObjectsDocs[workerId] = docsIds;
    });
    bookingsObjectsDocs.forEach((workerId, bookingsObjectsDocs) {
      //delete all the bookingsObjectsDocs
      bookingsObjectsDocs.forEach((bookingsObjectsDoc) {
        firestoreDataBase.deleteDoc(
            batch: batch,
            path:
                "$workersPath/$workerId/$dataCollection/$dataDoc/$bookingsObjectsCollection",
            docId: bookingsObjectsDoc);
      });

      // delete bookingData from bookings collection of the worker
      firestoreDataBase.deleteDoc(
          batch: batch,
          path: "$workersPath/$workerId/$dataCollection",
          docId: dataDoc);

      // delete permission from user
      firestoreDataBase.updateFieldInsideDocAsMap(
          batch: batch,
          path: "$usersCollection/$workerId/$dataCollection",
          docId: dataDoc,
          fieldName: "permission.${businessId}");

      // delete workers from workers collection
      firestoreDataBase.deleteDoc(
          batch: batch, path: workersPath, docId: workerId);
    });

    // delete settings file
    firestoreDataBase.deleteDoc(
        batch: batch, path: buisnessCollection, docId: businessId);

    if (productId != "" || workerProductId != "") {
      /*remove from user productsIds */
      firestoreDataBase.updateMultipleFieldsInsideDocAsMap(
          batch: batch,
          path: usersCollection,
          docId: user.phoneNumber,
          data: productId != "" && workerProductId != ""
              ? {
                  "productsIds.${productId}.businessId": "",
                  "productsIds.$workerProductId.businessId": ""
                }
              : productId != ""
                  ? {
                      "productsIds.${productId}.businessId": "",
                    }
                  : {"productsIds.$workerProductId.businessId": ""});
    }
    if (isExistInPreviews) {
      firestoreDataBase.updateMultipleFieldsInsideDocAsMap(
          batch: batch,
          path: buisnessesPreviewCollection,
          docId: previewDoc,
          data: {
            "amount": NumericCommands.decrement,
            "businesses.${businessId}": null
          });
    } else {
      firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: usersCollection,
        docId: user.phoneNumber,
        fieldName: "previews.${businessId}",
      );
    }

    /*delete in firestore, storage and realTime */
    return await firebaseStorage
        .deleteAllFiles(path: '$businessId/images')
        .then(
      (value) async {
        if (value) {
          return await firestoreDataBase
              .commmitBatch(batch: batch)
              .then((value) async {
            if (value) {
              realTimeDatabase.removeChild(
                  childPath: "$buisnessCollection/$businessId");
            }

            return value;
          });
        }
        return value;
      },
    );
  }

  Future<bool> userToWorker(
      {required String userPhone,
      required String buisnessId,
      required dynamic valueAsJson}) async {
    final batch = firestoreDataBase.batch;
    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: "$usersCollection/$userPhone/$dataCollection",
        docId: dataDoc,
        fieldName: "permission.$buisnessId",
        value: 1);
    firestoreDataBase.setDoc(
        batch: batch,
        path:
            "$buisnessCollection/$buisnessId/$workersCollection/$userPhone/$dataCollection",
        docId: dataDoc,
        valueToSet: {"bookingsTimes": {}});

    firestoreDataBase.createDoc(
        batch: batch,
        path: "$buisnessCollection/$buisnessId/$workersCollection",
        valueAsJson: valueAsJson,
        docId: userPhone);
    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  Future<bool> deleteWorker({
    required String workerPhone,
    required String buisnessId,
  }) async {
    final batch = firestoreDataBase.batch;
    final workersPath = "$buisnessCollection/${buisnessId}/$workersCollection";
    final docsIds = await getAllDocIdsInsideCollection(
        path:
            "$workersPath/$workerPhone/$dataCollection/$dataDoc/$bookingsObjectsCollection");

    //delete all bookingsObjects docs
    docsIds.forEach((docId) {
      firestoreDataBase.deleteDoc(
          batch: batch,
          path:
              "$workersPath/$workerPhone/$dataCollection/$dataDoc/$bookingsObjectsCollection",
          docId: docId);
    });

    //delete data doc
    firestoreDataBase.deleteDoc(
        batch: batch,
        path: "$workersPath/$workerPhone/$dataCollection",
        docId: dataDoc);

    // delete permission from user
    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path: "$usersCollection/$workerPhone/$dataCollection",
        docId: dataDoc,
        fieldName: "permission.$buisnessId");

    // delete worker from workers collection
    firestoreDataBase.deleteDoc(
        batch: batch, path: workersPath, docId: workerPhone);

    realTimeDatabase.removeChild(
        childPath:
            "$buisnessCollection/$buisnessId/$workersCollection/$workerPhone");

    /*delete worker story images from storage*/
    await getDoc(path: "$workersPath", docId: workerPhone).then(
      (workerDocJson) async {
        if (workerDocJson.exists && workerDocJson.data() != null) {
          final workerObj =
              WorkerModel.fromWorkerDocJson(workerDocJson.data()!);
          Set<String> imagesIds = {};
          workerObj.storyImages.values.forEach((fullPath) {
            imagesIds.add(
                DbPathesHelper().getImageStorageName("story_images", fullPath) +
                    ".jpg");
          });

          await firebaseStorage.deleteSetFromPathFiles(
              imagesId: imagesIds, path: '$buisnessId/images/stories');
        }
      },
    );

    return await firestoreDataBase.commmitBatch(batch: batch);
  }

//---------------------------bookings -------------------------------

  Future<bool> addBooking(
      {required Booking booking,
      required String workerPhone,
      required String currentUserPhone,
      required bool fromUpdate,
      required String clientPhone,
      required bool fromWorkerSchedule,
      required Map<String, int> treatmentDurations,
      bool userLoggedIn = true}) async {
    String bookingDate = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    String bookingTime = DateFormat('HH:mm').format(booking.bookingDate);
    String path =
        "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection";

    Map<String, dynamic> treatmentData = {};
    treatmentDurations.forEach((time, duration) {
      treatmentData["bookingsTimes.$bookingDate.$time"] = duration;
    });

    //bool createDocForAnonymous = false;
    // create the commands for the transactions
    Future<dynamic> Function(Transaction) transacionCommands =
        (transaction) async {
      bool addToUser = userLoggedIn;
      //bool createDocForAnonymous = false;
      // if worker is ordering for client - check if the user is exist
      if (clientPhone == "") addToUser = false;
      if (fromWorkerSchedule &&
          workerPhone == currentUserPhone &&
          clientPhone != "") {
        final user = await firestoreDataBase.transactionGet(
            transaction: transaction,
            path: "$usersCollection/$clientPhone/$dataCollection",
            docId: dataDoc);
        addToUser = user.exists;
        if (user.exists && user.data() != null) {
          booking.deviceFCM = user.data()['currentFcm'] ?? "";
        }
      }
      // if (booking.anonymousDocId != '') {
      //   final anonymosDoc = await firestoreDataBase.transactionGet(
      //       transaction: transaction,
      //       path: anonymousCollection,
      //       docId: booking.anonymousDocId);
      //   createDocForAnonymous = !anonymosDoc.exists;
      // }

      /*get the worker and make sure the time still avilable to set booking*/
      WorkerModel firestoreDataBaseWorker = WorkerModel.fromWorkerDocJson(
          (await firestoreDataBase.transactionGet(
                  transaction: transaction, path: path, docId: workerPhone))
              .data());
      /*get the publicData of the worker to merge it with the 
        worker that created before*/
      await firestoreDataBase
          .transactionGet(
              transaction: transaction,
              path: "$path/$workerPhone/$dataCollection",
              docId: dataDoc)
          .then((json) {
        if (json.exists) {
          firestoreDataBaseWorker.setWorkerPublicData(json.data()!);
        }
      });
      /* checking the time for booking is still 
      allowed - didn't take right before O(1) */
      bool allowedTime = isOptionalTimeForBooking(firestoreDataBaseWorker,
          booking, DateFormat('HH:mm').parse(bookingTime));
      if (allowedTime) {
        // put the time and duration into the booking data doc
        firestoreDataBase.transactionUpdateMultipleFieldsAsMap(
            transaction: transaction,
            path: "$path/$workerPhone/$dataCollection",
            docId: dataDoc,
            data: treatmentData);

        // put the boooking object in the worker collection
        if (firestoreDataBaseWorker.bookingsTime.containsKey(bookingDate)) {
          firestoreDataBase.transactionUpdateAsMap(
              transaction: transaction,
              path:
                  "$path/$workerPhone/$dataCollection/$dataDoc/$bookingsObjectsCollection",
              docId: bookingDate,
              fieldName: booking.bookingId,
              value: booking.toJson());
        } else {
          firestoreDataBase.transactionCreateDoc(
              transaction: transaction,
              path:
                  "$path/$workerPhone/$dataCollection/$dataDoc/$bookingsObjectsCollection",
              docId: bookingDate,
              value: {booking.bookingId: booking.toJson()});
        }

        //put the booking object in the user doc
        addToUser
            // the worker is order for client or anonymous
            ? firestoreDataBase.transactionUpdateAsMap(
                transaction: transaction,
                path: "$usersCollection/$clientPhone/$dataCollection",
                docId: dataDoc,
                fieldName: "bookings.${booking.bookingId}",
                value: booking.toJson())
            : logger.i("User dosen't exist");

        // if (createDocForAnonymous) {
        //   firestoreDataBase.transactionSetAsMap(
        //       transaction: transaction,
        //       path: anonymousCollection,
        //       docId: booking.anonymousDocId,
        //       fieldName: "bookings",
        //       value: {});
        // }
        // booking.anonymousDocId != ''
        //     ? firestoreDataBase.transactionUpdateAsMap(
        //         transaction: transaction,
        //         path: anonymousCollection,
        //         docId: booking.anonymousDocId,
        //         fieldName: "bookings.${booking.bookingId}",
        //         value: booking.toJson())
        //     : logger.i("User dosen't exist");

        return true;
      }
      AppErrors.error = Errors.takenBooking;
      logger.d("Cant order the booking to this time already taken");
      return false;
    };
    return await firestoreDataBase
        .runTransaction(transacionCommands: transacionCommands)
        .then((value) {
      if (value && fromWorkerSchedule && !fromUpdate) {
        NotificationsHelper().notifyWorkerOrderedBooking(booking);
      }
      return value;
    });
  }

  Future<bool> addBreak(
      {required BreakModel breakModel, required String workerPhone}) async {
    String path =
        "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection";
    if (breakModel.duration.inMinutes <= 0) return false; // prevent ui hacking
    // create the commands for the transactions
    Future<dynamic> Function(Transaction) transacionCommands =
        (transaction) async {
      /*get the worker and make sure the time still avilable to set booking*/
      WorkerModel firestoreDataBaseWorker = WorkerModel.fromWorkerDocJson(
          (await firestoreDataBase.transactionGet(
                  transaction: transaction, path: path, docId: workerPhone))
              .data());
      /*get the publicData of the worker to merge it with the 
        worker that created before*/
      await firestoreDataBase
          .transactionGet(
              transaction: transaction,
              path: "$path/$workerPhone/$dataCollection",
              docId: dataDoc)
          .then((json) {
        if (json.exists) {
          firestoreDataBaseWorker.setWorkerPublicData(json.data()!);
        }
      });

      Booking booking = getFakeBookingFromBreak(breakModel);

      bool resp = isOptionalTimeForBooking(firestoreDataBaseWorker, booking,
          DateFormat("HH:mm").parse(breakModel.start));

      if (resp) {
        firestoreDataBase.transactionUpdateAsMap(
            transaction: transaction,
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: workerPhone,
            fieldName: "breaks.${breakModel.id}",
            value: breakModel.toJson());
      }
      return resp;
    };

    return await firestoreDataBase.runTransaction(
        transacionCommands: transacionCommands);
  }

  Future<bool> updateVacations(
      {required Map<String, List<String>> vacations,
      required String workerPhone}) async {
    String path =
        "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection";

    // create the commands for the transactions
    Future<dynamic> Function(Transaction) transacionCommands =
        (transaction) async {
      /*get the worker and make sure the time still avilable to set booking*/
      WorkerModel firestoreDataBaseWorker = WorkerModel.fromWorkerDocJson(
          (await firestoreDataBase.transactionGet(
                  transaction: transaction, path: path, docId: workerPhone))
              .data());
      /*get the publicData of the worker to merge it with the 
        worker that created before*/
      await firestoreDataBase
          .transactionGet(
              transaction: transaction,
              path: "$path/$workerPhone/$dataCollection",
              docId: dataDoc)
          .then((json) {
        if (json.exists) {
          firestoreDataBaseWorker.setWorkerPublicData(json.data()!);
        }
      });
      Set<String> takenDays = {
        ...firestoreDataBaseWorker.breaks.values.map((e) => e.day).toSet()
      };
      firestoreDataBaseWorker.bookingsTime.forEach(
        (key, value) {
          if (value.length > 0) {
            takenDays.add(key);
          }
        },
      );

      for (MapEntry<String, List<String>> vacation in vacations.entries) {
        if (vacation.value.isEmpty && takenDays.contains(vacation.key)) {
          logger.i(
              'Event during full day vacation - block vacation: ${vacation.key}');
          // all day free and has event during the day - forbbiden
          AppErrors.error = Errors.coincidingEvent;
          return false;
        } else {
          // check each segment don't strike with event
          for (int i = 0; i < vacation.value.length - 1; i += 2) {
            Booking booking = getFakeBookingFromTime(
                // create fake event
                vacation.key,
                vacation.value[i],
                vacation.value[i + 1]);
            // checking if optionaly to book it
            bool resp = isOptionalTimeForBooking(firestoreDataBaseWorker,
                booking, DateFormat("HH:mm").parse(vacation.value[i]));
            if (!resp) {
              AppErrors.error = Errors.coincidingEvent;
              return false;
            }
          }
        }
      }
      firestoreDataBase.transactionUpdateAsMap(
          transaction: transaction,
          path:
              "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
          docId: workerPhone,
          fieldName: "vacations",
          value: vacations);
      return true;
    };

    return await firestoreDataBase.runTransaction(
        transacionCommands: transacionCommands);
  }

  Future<bool> setHolidays(
      {required List<Religion> religions,
      required WorkerModel worker,
      bool changeCloseScheduleOnHolidays = true}) async {
    String path =
        "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection";
    if (!changeCloseScheduleOnHolidays) {
      bool needTransaction = false;
      /*need transaction only when there is new religion */
      religions.forEach((religion) {
        if (!worker.religions.contains(religion)) {
          needTransaction = true;
          return;
        }
      });
      if (!needTransaction) {
        /*When changeCloseScheduleOnHolidays alaways need transaction*/
        final religionsToString = religions
            .map(
              (e) => religionToStr[e],
            )
            .toList();
        logger.d("No need to enter Transation for adding holidays");

        return await updateFieldInsideDocAsMap(
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: worker.phone,
            fieldName: "religions",
            value: religionsToString);
      }
    }

    //create the commands for the transactions
    Future<dynamic> Function(Transaction) transacionCommands =
        (transaction) async {
      logger.d("Enter Transation for adding holidays");
      /*Get the publicData of the worker to merge it with the
        worker that */
      await firestoreDataBase
          .transactionGet(
              transaction: transaction,
              path: "$path/${worker.phone}/$dataCollection",
              docId: dataDoc)
          .then((json) {
        if (json.exists) {
          worker.setWorkerPublicData(json.data()!);
        }
      });
      bool isOverlap = false;
      religions.forEach((religion) {
        worker.bookingsTime.forEach((date, times) {
          if (times.isNotEmpty) {
            if (religion == Religion.christian) {
              /*Need to format it like a christian holidays */
              final dateString = date.substring(0, date.length - 4) + "0000";
              if (holidays[religion]!.containsKey(dateString)) {
                isOverlap = true;
                return;
              }
            } else {
              if (holidays[religion]!.containsKey(date)) {
                isOverlap = true;
                return;
              }
            }
          }
        });
      });

      if (isOverlap) {
        AppErrors.error = Errors.coincidingEvent;
        return false;
      }
      if (changeCloseScheduleOnHolidays) {
        firestoreDataBase.transactionUpdateAsMap(
            transaction: transaction,
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: worker.phone,
            fieldName: "closeScheduleOnHolidays",
            value: true);
      } else {
        final religionsToString = religions
            .map(
              (e) => religionToStr[e],
            )
            .toList();
        firestoreDataBase.transactionUpdateAsMap(
            transaction: transaction,
            path:
                "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection",
            docId: worker.phone,
            fieldName: "religions",
            value: religionsToString);
      }
      return true;
    };

    return await firestoreDataBase
        .runTransaction(transacionCommands: transacionCommands)
        .then((value) {
      print("dddddddddddd");
      print(value);
      return value;
    });
  }

  Future<bool> deleteBooking(
      {required Booking booking,
      required String workerId,
      required String currentUserId,
      required Map<String, int> treatmentDurations,
      required String customerId,
      bool userLoggedIn = true}) async {
    final batch = firestoreDataBase.batch;
    String bookingDate = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    String path =
        "$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection";

    Map<String, dynamic> treatmentData = {};
    treatmentDurations.forEach((time, duration) {
      treatmentData["bookingsTimes.$bookingDate.$time"] = null;
    });

    //delete from booking data doc
    firestoreDataBase.updateMultipleFieldsInsideDocAsMap(
        batch: batch,
        path: "$path/${booking.workerId}/$dataCollection",
        docId: dataDoc,
        data: treatmentData);

    //delete from bookings objects Collection
    firestoreDataBase.updateFieldInsideDocAsMap(
        batch: batch,
        path:
            "$path/${booking.workerId}/$dataCollection/$dataDoc/$bookingsObjectsCollection",
        docId: bookingDate,
        fieldName: booking.bookingId);

    // if (booking.anonymousDocId != '') {
    //   firestoreDataBase.updateFieldInsideDocAsMap(
    //       batch: batch,
    //       path: anonymousCollection,
    //       docId: booking.anonymousDocId,
    //       fieldName: "bookings.${booking.bookingId}");
    //   return await firestoreDataBase.commmitBatch(batch: batch);
    // }

    workerId == currentUserId // the worker deleting for customer
        ? await firestoreDataBase
            .getDoc(path: usersCollection, docId: customerId)
            .then((doc) {
            if (doc.exists) {
              logger.d("Delete user booking");
              // user is exist
              firestoreDataBase.updateFieldInsideDocAsMap(
                batch: batch,
                path: "$usersCollection/$customerId/$dataCollection",
                docId: dataDoc,
                fieldName: "bookings.${booking.bookingId}",
              );
            } else {
              logger.i("User not exist");
            }
          }, onError: (_) {
            // iser dosen't exist
            logger.i("Adding only for worker");
          })
        : firestoreDataBase.updateFieldInsideDocAsMap(
            batch: batch,
            path: "$usersCollection/$customerId/$dataCollection",
            docId: dataDoc,
            fieldName: "bookings.${booking.bookingId}");

    return await firestoreDataBase.commmitBatch(batch: batch);
  }

  // ------- user Notifications --------
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
}
