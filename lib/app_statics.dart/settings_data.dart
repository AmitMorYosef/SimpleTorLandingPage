import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_tor_web/app_const/app_sizes.dart';
import 'package:simple_tor_web/app_const/db.dart';
import 'package:simple_tor_web/app_statics.dart/user_data.dart';
import 'package:simple_tor_web/app_statics.dart/worker_data.dart';
import 'package:simple_tor_web/services/clients/firebase_real_time_client.dart';
import 'package:simple_tor_web/services/clients/firebase_storage_client.dart';
import 'package:simple_tor_web/services/clients/firestore_client.dart';
import 'package:simple_tor_web/services/clients/secured_storage_client.dart';
import 'package:simple_tor_web/utlis/general_utlis.dart';

import '../app_const/application_general.dart';
import '../app_const/device_keys.dart';
import '../app_const/purchases.dart';
import '../models/booking_model.dart';
import '../models/buisnesses_preview_model.dart';
import '../models/general_settings_model.dart';
import '../models/preview_model.dart';
import '../models/worker_model.dart';
import '../providers/booking_provider.dart';
import '../providers/helpers/db_pathes_helper.dart';
import '../providers/helpers/notifications_helper.dart';
import '../services/errors_service/app_errors.dart';
import '../services/errors_service/messages.dart';
import '../services/errors_service/settings.dart';
import '../ui/pages/buisness_page/buisness.dart';
import '../ui/pages/buisness_page/widgets/story.dart';
import '../ui/ui_manager.dart';
import '../utlis/image_utlis.dart';
import 'general_data.dart';

class SettingsData {
  static String appCollection =
      '972-504040624--e6b8f8e0-a7b3-11ed-894b-dda94c48fa31'; // hold the current buisness collection reference
  static bool activeBusiness = true;
  static SubType businessSubtype = SubType.trial;
  static List<String> developers = [];
  static late GeneralSettingsModel
      settings; // hold app settings (server settings)
  static List<CachedNetworkImage> changingImages = []; // cached changing images
  static List<CachedNetworkImage> productsCacheImages =
      []; // cached products images
  static Map<String, Map<String, CachedNetworkImage>> storyCacheImages =
      {}; // cached story images --{$"workerPhone": {"imageId": networkImage}}

  static Map<String, WorkerModel?> workers = {}; // the buisness workers

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      workerObjListener;

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      publicDataListener;

  static Map<String, Map<String, Map<String, Booking>>> workersBookings = {};

  static BuisnessesPreview buisnessesPreview =
      BuisnessesPreview(); // hold the current manger

  static int storyImagesLength = 0;
  static CacheManager businessCacheManager = CacheManager(
    Config(
      'businessImages',
      maxNrOfCacheObjects: 20,
      stalePeriod: Duration(days: 7),
    ),
  );
  static String? businessIcon;

  static int eligibleWorkerAmount = 0;

  static List<BuisnessLimitations> limitionPassed = [];

  static Future<bool> initSettings(
      String buisnessId, BuildContext context) async {
    try {
      AppErrors.addError(
          code: settingsCodeToInt[SettingsErrorCodes.initSettings]);
      if (!buisnessesPreview.buisnesses.containsKey(buisnessId)) {
        return true;
      }
      businessSubtype = SubType.trial;
      workers = {};
      changingImages = [];
      storyCacheImages = {};
      productsCacheImages = [];
      limitionPassed = [];
      appCollection = buisnessId;
      eligibleWorkerAmount = 0;
      storyImagesLength = 0;
      GeneralData.currentBusinesssId = buisnessId;
      //use the current buisness in user provider for comfort
      UserData.currentBuisness = appCollection;
      await FirestoreClient()
          .getDoc(path: buisnessCollection, docId: appCollection)
          .then((doc) async {
        settings = GeneralSettingsModel.fromJson(doc.data());
        changingImages = await cacheImages(
          settings.changingImages,
          context,
          gWidthOriginal * 2,
          changingImagesHeight * 2,
        );
        productsCacheImages += await cacheImages(
          settings.products.values
              .map<String>((product) => product.imageUrl)
              .toList(),
          context,
          gWidth,
          gWidth * (productImageRatioY / productImageRatioX),
        );
      });
      /*Insure subs are updated */
      updateSubs();

      String workersPath =
          "$buisnessCollection/$appCollection/$workersCollection";

      activeBusiness = await isBusinessActive();

      await FirestoreClient()
          .getAllDocInsideCollection(path: workersPath)
          .then((workersJsonsList) async {
        if (workersJsonsList != null)
          await Future.forEach(workersJsonsList, (workerJson) async {
            // get the workers and all their the relative data
            final workerObj = WorkerModel.fromWorkerDocJson(workerJson);
            await FirestoreClient()
                .getDoc(
                    path: "$workersPath/${workerObj.phone}/$dataCollection",
                    docId: dataDoc)
                .then((json) {
              if (json.exists) {
                workerObj.setWorkerPublicData(json.data()!);
              }
            });

            await cacheStoryImages(
                workerObj.storyImages, context, workerObj.phone);

            storyImagesLength += workerObj.storyImages.length;

            String managerId = buisnessId.split("--")[0];
            if (managerId == workerObj.phone.replaceAll("+", "")) {
              logger.d("Found manager --> $managerId");
              NotificationsHelper().notifyFirstTimeEnterBusiness(
                  workerObj,
                  UserData.user,
                  buisnessId,
                  settings.shopName,
                  settings.notifyOnNewCustomer);
            }
            // fill the workers in settings provider
            workers[workerObj.phone] = workerObj;
            // fill the workers in booking provider
            BookingProvider.workers[workerObj.phone] = workerObj;
          });
      });

      businessSubtype = subTypeFromProductId(settings.productId, buisnessId);

      updateBusinessLimits(businessSubtype);

      updateNotifyOnNewCustomerIfNeeded();

      return true;
    } catch (e) {
      await emptyBusinessData();
      logger.e("Error while init settings --> $e");
      return false;
    }
  }

  //------------------------- listeners ------------------------

  static void startListening(String workerPhone) {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.startListening]);
    try {
      //make listener for worker obj doc
      final workerDocListener = FirestoreClient().docListener(
          path: "$buisnessCollection/${appCollection}/$workersCollection",
          docId: workerPhone);
      workerObjListener = workerDocListener.listen((workerListenerJson) {
        updateWorkerObj(workerListenerJson, workerPhone);
      });

      //make listener for public data of the worker
      final workerPublicDataListner = FirestoreClient().docListener(
          path:
              "$buisnessCollection/${appCollection}/$workersCollection/$workerPhone/$dataCollection",
          docId: dataDoc);
      publicDataListener =
          workerPublicDataListner.listen((workerBookingsListenerJson) {
        updateWorkerPublicData(workerBookingsListenerJson, workerPhone);
      });
    } catch (e) {
      logger.d("Error while resuming the Worker lisntner --> $e");
    }
  }

  static void updateWorkerPublicData(
    DocumentSnapshot<Map<String, dynamic>> bookingsDocListenerJson,
    String workerPhone,
  ) {
    if (workers[workerPhone] == null) return;
    if (!bookingsDocListenerJson.exists) return;
    workers[workerPhone]!.setWorkerPublicData(bookingsDocListenerJson.data()!);

    //update the worker inside booking provider
    BookingProvider.updateWorkerData(workers[workerPhone]!);
    logger.d("Get new workerData for the current worker --> $workerPhone");

    UiManager.insertUpdate(Providers.booking);
    UiManager.updateUi(context: GeneralData.generalContext!);
  }

  static void updateWorkerObj(
      DocumentSnapshot<Map<String, dynamic>> workerListenerJson,
      String workerPhone) {
    if (workerListenerJson.exists)
      workers[workerPhone]!.setFromWorkerDoc(workerListenerJson.data()!);
    else {
      BookingProvider.workers.remove(workerPhone);
      workers.remove(workerPhone);
      UiManager.insertUpdate(Providers.booking);
      UiManager.updateUi(context: GeneralData.generalContext!);
      return;
    }

    //update the worker inside booking provider
    BookingProvider.updateWorkerData(workers[workerPhone]!);

    //update the currnet worker
    if (WorkerData.worker.phone == workerPhone) {
      WorkerData.worker = workers[workerPhone]!;
      UiManager.insertUpdate(Providers.worker);
    }
    logger.d("Get new worker for the current worker --> $workerPhone");

    UiManager.insertUpdate(Providers.booking);
    UiManager.updateUi(context: GeneralData.generalContext!);
  }

  static Future<void> cancelWorkerListening() async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.cancelWorkerListening]);
    try {
      /*cancel the two listeners public data and worker obj*/
      await workerObjListener!.cancel();
      await publicDataListener!.cancel();
      logger.d("Workers Listenings have canceled");
    } catch (e) {
      logger.d("Error while cancel the Workers lisntners");
    }
  }

  // -------------------------- Purchases --------------------------

  static bool isBusinessPublish() {
    return appCollection != "" &&
        !UserData.user.previews.containsKey(appCollection);
  }

  static Future<bool> isBusinessActive() async {
    final ownerPhone = appCollection.split("--")[0];
    if (developers.contains(ownerPhone)) return true;

    /*Give to the user few days trial without put the cerdit card*/
    if (UserData.getPermission() == 2 &&
        UserData.user.previews.containsKey(appCollection)) return true;

    return settings.productId != "";
  }

  static void updateSubs() {
    /*update the business products Ids base on the 
      updated user productsIds that get update already
      in the user setUp */
    if (UserData.getPermission() != 2) return;
    final activeProducts = UserData.user.productsIds;

    /*Insure that the product is belong to this business*/
    if (!activeProducts.containsKey(settings.productId) ||
        activeProducts[settings.productId]!["businessId"] != appCollection) {
      settings.productId = "";
      FirestoreClient().updateFieldInsideDocAsMap(
          path: buisnessCollection,
          docId: appCollection,
          fieldName: "productId",
          value: "");
    }

    if (!activeProducts.containsKey(settings.workersProductsId) ||
        activeProducts[settings.workersProductsId]!["businessId"] !=
            appCollection) {
      settings.workersProductsId = "";
      FirestoreClient().updateFieldInsideDocAsMap(
          path: buisnessCollection,
          docId: appCollection,
          fieldName: "workersProductsId",
          value: "");
    }

    /*Update the subs to the correct subs base on the users productsIds*/
    activeProducts.forEach((productId, details) {
      if (productId != settings.productId &&
          productId.contains("business") &&
          details["businessId"] == appCollection) {
        settings.productId = productId;
        FirestoreClient().updateFieldInsideDocAsMap(
            path: buisnessCollection,
            docId: appCollection,
            fieldName: "productId",
            value: productId);
      }
      if (productId != settings.workersProductsId &&
          productId.contains("worker") &&
          details["businessId"] == appCollection) {
        settings.workersProductsId = productId;
        FirestoreClient().updateFieldInsideDocAsMap(
            path: buisnessCollection,
            docId: appCollection,
            fieldName: "workersProductsId",
            value: productId);
      }
    });
  }

  static bool isPassedLimit() {
    return limitionPassed.isNotEmpty && UserData.getPermission() > 0;
  }

  static void updateBusinessLimits(
    SubType subType,
  ) {
    //update the limits acourding to the business subtype
    Map<BuisnessLimitations, int> limits = {};
    switch (subType) {
      case SubType.basic:
        limits = limitsForBasicBusiness;
        break;
      case SubType.advanced:
        limits = limitsForAdvancedBusiness;
        break;
      case SubType.trial:
        limits = limitsForTrialBusiness;
        break;
    }

    limits.forEach((key, value) {
      settings.limits[key] = value;
    });
    limitionPassed = whoPassedTheLimit();
  }

  static List<BuisnessLimitations> whoPassedTheLimit() {
    List<BuisnessLimitations> passedTheLimit = [];
    if (eligibleWorkerAmount < workers.length - 1) {
      passedTheLimit.add(BuisnessLimitations.workers);
    }
    if (settings.limits[BuisnessLimitations.products]! <
        settings.products.length) {
      passedTheLimit.add(BuisnessLimitations.products);
    }
    if (settings.limits[BuisnessLimitations.changingPhotos]! <
        settings.changingImages.length) {
      passedTheLimit.add(BuisnessLimitations.changingPhotos);
    }
    if (settings.limits[BuisnessLimitations.storyPhotos]! < storyImagesLength) {
      passedTheLimit.add(BuisnessLimitations.storyPhotos);
    }
    return passedTheLimit;
  }

  static void setActiveBusiness({required String productId}) {
    activeBusiness = true;
    businessSubtype = subTypeFromProductId(productId, appCollection);
    UiManager.insertUpdate(Providers.settings);
  }

  static Future<bool> updateBusinessFont({required String fontName}) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.setupPreviewBuisnesses]);
    // check for no change can't be here cause changing localy when font is selected
    return await FirestoreClient().updateFieldInsideDocAsMap(
        path: buisnessCollection,
        docId: appCollection,
        fieldName: "fontName",
        value: fontName);
  }

  static void addPreviewBuisness(Preview preview) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.addPreviewBuisness]);
    if (!buisnessesPreview.buisnesses.containsKey(preview.buisnessId)) {
      buisnessesPreview.buisnesses[preview.buisnessId] = preview;
      UiManager.insertUpdate(Providers.settings);
    }
  }

  static void removePreviewBuisness(String businessId) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.removePreviewBuisness]);
    if (buisnessesPreview.buisnesses.containsKey(businessId)) {
      buisnessesPreview.buisnesses.remove(businessId);
      UiManager.insertUpdate(Providers.settings);
    }
  }

  static Future<void> emptyBusinessData() async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.emptyBuisnessData]);
    appCollection = '';
    changingImages = [];
    storyCacheImages = {};
    productsCacheImages = [];
    Buisness.editMode = false;
    Story.imagesToDelete = {};
    storyImagesLength = 0;
    eligibleWorkerAmount = 0;
    limitionPassed = [];
    UserData.currentBuisness = "";
    businessSubtype = SubType.trial;
    WorkerData.alreadyLoadData = false;
    WorkerData.monthlyBookingsData = {};
    settings = GeneralSettingsModel.empty();
    BookingProvider.workers = {};
    GeneralData.currentBusinesssId = '';
    UiManager.insertUpdate(Providers.settings);
    await deleteLastBuisness();
  }

  static Future<bool> deleteLastBuisness() async {
    return await SecuredStorageClient()
        .updateKeyInDeviceStorage(key: lastBuisnessIdKey, value: '');
  }

  static Future<bool> updateLastBuisness(String buisnessId) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateLastBuisness]);
    if (buisnessId.length < 10) return true;
    return await SecuredStorageClient()
        .updateKeyInDeviceStorage(key: lastBuisnessIdKey, value: buisnessId);
  }

  static Future<void> updateNotifyOnNewCustomerIfNeeded() async {
    AppErrors.addError(
        code: settingsCodeToInt[
            SettingsErrorCodes.updateNotifyOnNewCustomerIfNeeded]);
    if (businessSubtype == SubType.basic &&
        settings.notifyOnNewCustomer == true) {
      await FirestoreClient()
          .updateFieldInsideDocAsMap(
              path: buisnessCollection,
              docId: appCollection,
              fieldName: "notifyOnNewCustomer",
              value: false)
          .then((value) {
        if (value) {
          settings.notifyOnNewCustomer = false;
          logger.d("Update settings notifyOnNewCustomer successfully");
        }
        return value;
      });
    }
  }

  static Future<List<CachedNetworkImage>> cacheImages(List<String> imageUrls,
      BuildContext context, double width, double height) async {
    AppErrors.addError(code: settingsCodeToInt[SettingsErrorCodes.cacheImages]);
    List<CachedNetworkImage> saveCache = [];
    imageUrls.forEach((url) => saveCache.add(
          new CachedNetworkImage(
            cacheManager: businessCacheManager,
            key: Key(url),
            width: width,
            height: height,
            fit: BoxFit.cover,
            imageUrl: url,
            placeholder: (context, url) => Center(
              child: showCircleCachedImage(
                  settings.shopIconUrl, gHeight * 0.08, businessIcon!),
            ),
            errorWidget: (context, url, error) =>
                Center(child: Icon(Icons.error)),
          ),
        ));
    return saveCache;
  }

  static Future<void> cacheStoryImages(Map<String, String> storyImages,
      BuildContext context, String workerPhone) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.cacheStoryImages]);

    storyCacheImages[workerPhone] = {};
    storyImages.forEach((id, imageString) {
      final image = CachedNetworkImage(
        cacheManager: businessCacheManager,
        width: storyImagesWidth * 2,
        height: storyImagesHeigth * 2,
        fit: BoxFit.cover,
        imageUrl: imageString,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
              border: GradientBoxBorder(
                gradient: LinearGradient(colors: [
                  Color(0xffFFFFFF).withOpacity(0.15),
                  Color(0x000000).withOpacity(0.1)
                ]),
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Center(
            child: showCircleCachedImage(
                settings.shopIconUrl, gHeight * 0.08, businessIcon!),
          ),
        ),
        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      );

      storyCacheImages[workerPhone]![id] = image;
    });
  }

  static Future<bool> uploadNewShopIcon(XFile image) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.uploadNewShopIcon]);
    final isExistInPreviews =
        !UserData.user.previews.containsKey(appCollection);
    return await FirebaseStorageClient()
        .uploadImage(
            image: image,
            imageType: 'shopIcon',
            dbCollection: buisnessCollection,
            dbDoc: appCollection,
            storagePath: shopeIconsPath)
        .then((path) async {
      if (path != '') {
        settings.shopIconUrl = path;
        final buisnessesPreviews = buisnessesPreview.buisnesses;

        if (!buisnessesPreviews.containsKey(appCollection)) {
          AppErrors.error = Errors.notFoundItem;
          return false;
        }

        return await FirestoreClient()
            .updateFieldInsideDocAsMap(
                path: isExistInPreviews
                    ? buisnessesPreviewCollection
                    : usersCollection,
                docId:
                    isExistInPreviews ? previewDoc : UserData.user.phoneNumber,
                fieldName: isExistInPreviews
                    ? 'businesses.${appCollection}.imageUrl'
                    : 'previews.$appCollection.imageUrl',
                value: path)
            .then((value) {
          if (value) {
            // change locally
            buisnessesPreviews[appCollection]!.imageUrl = path;
            UiManager.insertUpdate(Providers.settings);
          }
          return value;
        });
      }
      return false;
    });
  }

  static Future<bool> updateShopIcon(XFile? image) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateShopIcon]);
    if (image == null) return true;
    if (settings.shopIconUrl != "")
      await businessCacheManager.removeFile(settings.shopIconUrl);
    if (settings.shopIconUrl == "") return uploadNewShopIcon(image);
    return await FirebaseStorageClient()
        .updateImage(
            image: image,
            currentUrl: settings.shopIconUrl,
            imageType: 'shopIcon',
            storagePath: shopeIconsPath)
        .then((imageUrl) async {
      if (imageUrl == "") return false;
      settings.shopIconUrl = imageUrl;
      UiManager.insertUpdate(Providers.settings);
      return true;
    });
  }

  static Future<bool> deleteShopIcon() async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.deleteShopIcon]);
    final isExistInPreviews =
        !UserData.user.previews.containsKey(appCollection);
    return await FirebaseStorageClient()
        .deleteImage(
            imageUrl: settings.shopIconUrl,
            imageType: "shopIcon",
            userPhone: UserData.user.phoneNumber,
            isExistInPreviews: isExistInPreviews,
            dbDocId: appCollection,
            dbPath: buisnessCollection,
            storagePath: shopeIconsPath,
            dbFieldName: "shopIcon",
            changeInPreview: isExistInPreviews
                ? 'businesses.${appCollection}.imageUrl'
                : 'previews.$appCollection.imageUrl',
            dbValue: "",
            inArray: false)
        .then((resp) async {
      if (resp) {
        settings.shopIconUrl = '';
        businessCacheManager.removeFile(settings.shopIconUrl);
        final buisnessesPreviews = buisnessesPreview.buisnesses;
        if (!buisnessesPreviews.containsKey(appCollection)) {
          AppErrors.error = Errors.notFoundItem;
          return false;
        }
        // change locally
        if (isExistInPreviews) {
          final buisnessesPreviews = buisnessesPreview.buisnesses;
          if (!buisnessesPreviews.containsKey(appCollection)) {
            buisnessesPreviews[appCollection]!.imageUrl = '';
          }
        } else {
          if (UserData.user.previews.containsKey(appCollection))
            UserData.user.previews[appCollection]!.imageUrl = '';
        }
      }
      return resp;
    });
  }

  static void removeWorker(String workerPhone) {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.removeWorker]);
    if (!workers.containsKey(workerPhone)) return;
    storyImagesLength = -workers[workerPhone]!.storyImages.length;

    if (limitionPassed.contains(BuisnessLimitations.storyPhotos) &&
        settings.limits[BuisnessLimitations.storyPhotos]! >=
            storyImagesLength) {
      limitionPassed.remove(BuisnessLimitations.storyPhotos);
    }
    workers.remove(workerPhone);
    BookingProvider.workers.remove(workerPhone);
    if (eligibleWorkerAmount >= workers.length - 1 &&
        limitionPassed.contains(BuisnessLimitations.workers)) {
      limitionPassed.remove((BuisnessLimitations.workers));
    }

    UiManager.insertUpdate(Providers.settings);
  }

  static Future<bool> changeChangingImagesSwapSeconds(
      int seconds, BuildContext context) async {
    AppErrors.addError(
        code: settingsCodeToInt[
            SettingsErrorCodes.changeChangingImagesSwapSeconds]);
    settings.changingImagesSwapSeconds = seconds;
    UiManager.insertUpdate(Providers.settings);
    UiManager.updateUi(context: context);
    return await FirestoreClient().updateFieldInsideDocAsMap(
        fieldName: 'changingImagesSwapSeconds',
        docId: GeneralData.currentBusinesssId,
        path: buisnessCollection,
        value: seconds);
  }

  static Future<void> loadLikes(Map<String, String> likesToLoad) async {
    /*likesToLoad = {imageId : workerId} */

    await Future.forEach(likesToLoad.keys, (imageId) async {
      final workerId = likesToLoad[imageId]!;

      if (workers[workerId]!.storylikesAmount.containsKey(imageId)) {
        return;
      }

      await FirebaseRealTimeClient()
          .getChild(
              pathToChild: DbPathesHelper()
                  .getLikesChildPath(workerId, appCollection, imageId))
          .then((likesSnapshot) {
        final likes = likesSnapshot.value;
        workers[workerId]!.storylikesAmount[imageId] = (likes as int?) ?? 0;
      });
    });
  }

  static Future<void> changeNotifyOnNewCustomer(
      bool value, BuildContext context) async {
    if (appCollection == "") return;
    if (settings.notifyOnNewCustomer == value) return;
    if (businessSubtype == SubType.basic) return;

    settings.notifyOnNewCustomer = value;
    UiManager.insertUpdate(Providers.settings);
    UiManager.updateUi(context: context);

    FirestoreClient().updateFieldInsideDocAsMap(
        path: buisnessCollection,
        docId: appCollection,
        fieldName: "notifyOnNewCustomer",
        value: value);
  }
}
