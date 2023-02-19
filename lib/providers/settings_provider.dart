import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/app_const/business_types.dart';
import 'package:management_system_app/models/buisnesses_preview_model.dart';
import 'package:management_system_app/models/product_model.dart';
import 'package:management_system_app/providers/theme_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/services/clients/firebase_real_time_client.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/services/errors_service/settings.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../app_const/app_sizes.dart';
import '../app_const/application_general.dart';
import '../app_const/db.dart';
import '../app_const/device_keys.dart';
import '../app_const/display.dart';
import '../app_const/purchases.dart';
import '../app_statics.dart/general_data.dart';
import '../app_statics.dart/screens_data.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/theme_data.dart';
import '../app_statics.dart/user_data.dart';
import '../models/currency_model.dart';
import '../models/price_model.dart';
import '../models/update_model.dart';
import '../models/worker_model.dart';
import '../services/clients/firebase_storage_client.dart';
import '../services/clients/firestore_client.dart';
import '../services/clients/secured_storage_client.dart';
import '../services/errors_service/messages.dart';
import '../utlis/general_utlis.dart';
import '../utlis/string_utlis.dart';
import 'booking_provider.dart';
import 'helpers/db_pathes_helper.dart';

class SettingsProvider extends ChangeNotifier {
  // ---------------------buisness -------------------------

  Future<bool> setupPreviewBuisnesses() async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.setupPreviewBuisnesses]);
    return await FirestoreClient()
        .getAllDocInsideCollection(path: '$buisnessesPreviewCollection')
        .then((json) {
      if (json != null)
        SettingsData.buisnessesPreview = BuisnessesPreview.fromJson(json);

      return json != null;
    });
  }

  Future<bool> loadBuisness(BuildContext context, String buisnessId,
      {bool fromLoading = false}) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.loadBuisness]);
    //clean business data
    ScreensData.initOffests();
    ScreensData.changingPhotoIndex = 0;
    SettingsData.emptyBusinessData();
    UserData.currentBuisness = '';
    try {
      final buisnesses = SettingsData.buisnessesPreview.buisnesses;

      if (!buisnesses.containsKey(buisnessId)) {
        logger.i("Buisness isnt exist");
        AppErrors.error = Errors.notFoundItem;

        if (fromLoading) {
          return true;
        }
        return false;
      }
      // the settings
      bool resp = await SettingsData.initSettings(buisnessId, context);
      if (resp) {
        if (UserData.user.permission.containsKey(buisnessId)) {
          await context.read<WorkerProvider>().setUpWorker(
              userPhone: UserData.user.phoneNumber, context: context);
        }

        //we dont want to init the buisness when theme is changes
        if (!AppThemeData.themeCauseMainBuilt) ScreensData.buisnessInit = false;

        //add to the last visited buisnesses
        if (UserData.user.name != translate("guest") &&
            await isNetworkConnected()) {
          if (UserData.user.lastVisitedBuisnesses.contains(buisnessId)) {
            await context
                .read<UserProvider>()
                .replaceVisitedBuisness(buisnessId, buisnessId);
          } else {
            context.read<UserProvider>().addVisitedBuisness(buisnessId);
          }
        }
        // save the last buisness
        await SettingsData.updateLastBuisness(buisnessId);

        logger.d('The new buisness theme --> ${SettingsData.settings.theme}');
        //change theme according to buisness theme
        await context
            .read<ThemeProvider>()
            .changeTheme(context, SettingsData.settings.theme!);
        UiManager.insertUpdate(Providers.settings);
        return true;
      } else {
        AppErrors.error = Errors.unknown;
        return false;
      }
    } catch (e) {
      logger.e("Error loading settings --> $e");
      //check if buisness exist
      await SettingsData.emptyBusinessData();
      final buisnesses = SettingsData.buisnessesPreview.buisnesses;
      if (!buisnesses.containsKey(buisnessId)) {
        logger.i("Buisness isnt exist");

        AppErrors.error = Errors.notFoundItem;
      } else {
        AppErrors.error = Errors.unknown;
      }
      return true;
    }
  }

  Future<void> changeTheme(Themes theme) async {
    SettingsData.settings.theme = theme;
    await FirestoreClient().updateFieldInsideDocAsMap(
        fieldName: 'theme',
        docId: SettingsData.appCollection,
        path: buisnessCollection,
        value: themeToStr[theme]!);
  }

  Future<bool> loadLastBuisness(BuildContext context,
      {bool fromLoading = false}) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.loadLastBuisness]);
    String key = await SecuredStorageClient()
        .readKeyInDeviceStorage(key: lastBuisnessIdKey);
    logger.d("Saved business key is --> $key");
    if (key != '')
      await loadBuisness(context, key, fromLoading: fromLoading).then((value) {
        if (value) {
          UiManager.updateUi(
              context: context,
              perform: Future(() => (context.read<ThemeProvider>().changeTheme(
                  context, SettingsData.settings.theme ?? Themes.dark))));
        } else {
          logger.d("Failed to load the business");
          if (AppErrors.error == Errors.notFoundItem) {
            logger.i("Business not found, may be deleted - Rmoving from list");
            context.read<UserProvider>().removeDeletedLastVisitedBuisnesses();
          }
          //if fail we want to delete all the data that already pass
          SettingsData.emptyBusinessData();
        }
      });
    return true;
  }

//------------------------- images -----------------------

  Future<bool> deleteChangingImage(
      BuildContext context, String imageUrl) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.deleteChangingImage]);
    if (imageUrl != '' &&
        SettingsData.settings.changingImages.contains(imageUrl)) {
      return await FirebaseStorageClient()
          .deleteImage(
              imageUrl: imageUrl,
              userPhone: UserData.user.phoneNumber,
              imageType: "changing_Images",
              dbDocId: SettingsData.appCollection,
              dbPath: buisnessCollection,
              storagePath: changingImagesPath,
              dbFieldName: "changingImages")
          .then((resp) async {
        if (resp) {
          ScreensData.changingPhotoIndex = 0;
          SettingsData.settings.changingImages.remove(imageUrl);
          SettingsData.businessCacheManager.removeFile(imageUrl);
          SettingsData.changingImages = await SettingsData.cacheImages(
            SettingsData.settings.changingImages,
            context,
            gWidthOriginal * 2,
            changingImagesHeight * 2,
          );
          if (SettingsData.limitionPassed
                  .contains(BuisnessLimitations.changingPhotos) &&
              SettingsData
                      .settings.limits[BuisnessLimitations.changingPhotos]! >=
                  SettingsData.settings.changingImages.length) {
            SettingsData.limitionPassed
                .remove(BuisnessLimitations.changingPhotos);
          }
          UiManager.insertUpdate(Providers.settings);
        }
        return resp;
      });
    }
    return false;
  }

  Future<bool> deleteStoryImage(BuildContext context, String workerPhone,
      String imageId, String imageUrl) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.deleteStoryImage]);
    if (imageUrl == '') {
      AppErrors.error = Errors.notSelectedImages;
      return false;
    }
    if (!SettingsData.workers[workerPhone]!.storyImages.containsKey(imageId)) {
      AppErrors.error = Errors.notFoundItem;
      return false;
    }
    return await FirebaseStorageClient()
        .deleteImage(
            imageUrl: imageUrl,
            userPhone: UserData.user.phoneNumber,
            imageType: "story_Images",
            dbDocId: workerPhone,
            dbPath:
                "$buisnessCollection/${SettingsData.appCollection}/$workersCollection",
            storagePath: storyImagesPath,
            dbFieldName: "storyImages.$imageId",
            dbValue: null,
            inArray: false)
        .then((resp) async {
      if (resp) {
        // remove likes from real time
        FirebaseRealTimeClient().removeChild(
            pathToChild:
                '${DbPathesHelper().getLikesChildPath(workerPhone, SettingsData.appCollection, imageId)}');
        SettingsData.workers[workerPhone]!.storyImages.remove(imageId);
        SettingsData.businessCacheManager.removeFile(imageUrl);
        await SettingsData.cacheStoryImages(
            SettingsData.workers[workerPhone]!.storyImages,
            context,
            workerPhone);
        SettingsData.storyImagesLength--;

        if (SettingsData.limitionPassed
                .contains(BuisnessLimitations.storyPhotos) &&
            SettingsData.settings.limits[BuisnessLimitations.storyPhotos]! >=
                SettingsData.storyImagesLength) {
          SettingsData.limitionPassed.remove(BuisnessLimitations.storyPhotos);
        }
        UiManager.insertUpdate(Providers.settings);
      }
      return resp;
    });
  }

  Future<bool> saveProduct(
      {required BuildContext context,
      required XFile? image,
      required String name,
      required String description,
      required Price price}) async {
    AppErrors.addError(code: settingsCodeToInt[SettingsErrorCodes.saveProduct]);
    if (image == null ||
        image.path.length < 2 ||
        name == "" ||
        price == "" ||
        description == "") {
      AppErrors.error = Errors.illegalFields;
      return false;
    }
    return await FirebaseStorageClient()
        .uploadImage(
            image: image,
            imageType: "products_Images",
            storagePath: productsImagesPath,
            dbCollection: buisnessCollection,
            dbDoc: SettingsData.appCollection,
            updateDb: false)
        .then((path) async {
      if (path == '') return false;
      Uuid uuid = const Uuid();
      ProductModel product = ProductModel(
          name: name, price: price, description: description, imageUrl: path);
      String id = uuid.v1();
      return await FirestoreClient()
          .updateFieldInsideDocAsMap(
              path: buisnessCollection,
              docId: SettingsData.appCollection,
              fieldName: "products.${id}",
              value: product.toJson())
          .then((value) async {
        SettingsData.productsCacheImages += await SettingsData.cacheImages(
            [path],
            context,
            gWidth,
            gWidth * (productImageRatioY / productImageRatioX));

        SettingsData.settings.products[id] = product;
        UiManager.insertUpdate(Providers.settings);
        return value;
      });
    });
  }

  Future<bool> updateProduct(
      {required BuildContext context,
      required ProductModel newProduct,
      required String productId,
      XFile? image}) async {
    AppErrors.addError(code: settingsCodeToInt[SettingsErrorCodes.saveProduct]);
    if (newProduct == ProductModel()) {
      AppErrors.error = Errors.illegalFields;
      return false;
    }
    ProductModel copy =
        ProductModel.fromProduct(SettingsData.settings.products[productId]!);
    SettingsData.settings.products[productId] = newProduct;
    UiManager.insertUpdate(Providers.settings);
    if (image != null) {
      // updating the image
      await FirebaseStorageClient()
          .updateImage(
        image: image,
        imageType: "products_Images",
        storagePath: productsImagesPath,
        currentUrl: newProduct.imageUrl,
      )
          .then((path) async {
        await SettingsData.businessCacheManager.removeFile(newProduct.imageUrl);
        SettingsData.productsCacheImages = [];
        SettingsData.productsCacheImages = await SettingsData.cacheImages(
            SettingsData.settings.products.values
                .map<String>((product) => product.imageUrl)
                .toList(),
            context,
            gWidth,
            gWidth * (productImageRatioY / productImageRatioX));
      });
    }
    await FirestoreClient()
        .updateFieldInsideDocAsMap(
            path: buisnessCollection,
            docId: SettingsData.appCollection,
            fieldName: 'products.$productId',
            value: newProduct.toJson())
        .then((resp) {
      if (!resp) {
        SettingsData.settings.products[productId] = copy;
      }
    });
    return true;
  }

  Future<bool> deleteProduct(BuildContext context, String productId) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.deleteProduct]);
    if (!SettingsData.settings.products.containsKey(productId)) return false;
    String imageUrl = SettingsData.settings.products[productId]!.imageUrl;
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
            path: buisnessCollection,
            docId: SettingsData.appCollection,
            fieldName: "products.$productId")
        .then((resp) async {
      if (resp) {
        return await FirebaseStorageClient()
            .deleteImage(
                imageUrl: imageUrl,
                userPhone: UserData.user.phoneNumber,
                imageType: "products_images",
                dbDocId: "",
                dbPath: "",
                storagePath: productsImagesPath,
                dbFieldName: "changingImages",
                updateDb: false)
            .then((delResp) async {
          if (delResp) {
            SettingsData.settings.products.remove(productId);
            SettingsData.businessCacheManager.removeFile(imageUrl);
            SettingsData.productsCacheImages = await SettingsData.cacheImages(
                SettingsData.settings.products.values
                    .map<String>((product) => product.imageUrl)
                    .toList(),
                context,
                gWidth,
                gWidth * (productImageRatioY / productImageRatioX));
            if (SettingsData.settings.limits[BuisnessLimitations.products]! >=
                    SettingsData.settings.products.length &&
                SettingsData.limitionPassed
                    .contains(BuisnessLimitations.products)) {
              SettingsData.limitionPassed.remove(BuisnessLimitations.products);
            }
            UiManager.insertUpdate(Providers.settings);
            return true;
          }
          return false;
        });
      }
      return false;
    });
  }

  Future<bool> uploadChangingImages(
      BuildContext context, List<XFile>? images) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.uploadChangingImages]);
    if (images != null && images.length > 0) {
      return await FirebaseStorageClient()
          .uploadMultipleImages(images: images, imageType: "changing_Images")
          .then((imageUrls) async {
        SettingsData.settings.changingImages += imageUrls;
        SettingsData.changingImages += await SettingsData.cacheImages(
          imageUrls,
          context,
          gWidthOriginal * 2,
          changingImagesHeight * 2,
        );

        UiManager.insertUpdate(Providers.settings);
        if (imageUrls.length != images.length) {
          AppErrors.error = Errors.uploadImages;
          return false;
        }
        return true;
      });
    } else {
      AppErrors.error = Errors.notSelectedImages;
      return false;
    }
  }

  Future<bool> uploadStoryImages(
      BuildContext context, List<XFile>? images, String workerPhone) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.uploadStoryImages]);
    if (!SettingsData.workers.containsKey(workerPhone)) {
      AppErrors.error = Errors.noPermission;
      return false;
    }
    if (images != null && images.length != 0) {
      return await FirebaseStorageClient()
          .uploadStoryImages(images: images, workerPhone: workerPhone)
          .then((idsAndPaths) async {
        if (idsAndPaths == null) {
          return false;
        }
        idsAndPaths.forEach((id, path) {
          SettingsData.workers[workerPhone]!.storyImages[id] = path;
        });
        await SettingsData.cacheStoryImages(
            SettingsData.workers[workerPhone]!.storyImages,
            context,
            workerPhone);
        SettingsData.storyImagesLength += images.length;
        UiManager.insertUpdate(Providers.settings);
        return true;
      });
    } else {
      AppErrors.error = Errors.notSelectedImages;
      return false;
    }
  }

  // ---------------------- buisness details -----------------------

  // static int workerAmountLimit() {
  //   try {
  //     final entitlementId = SettingsData.settings.entitlementId;
  //     final workerAmount = entitlementId.split("_")[1];
  //     return int.parse(workerAmount);
  //   } catch (e) {
  //     return 1;
  //   }
  // }

  Future<bool> updateShopName(String name) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateShopName]);
    if (name != '') {
      final isExistInPreviews =
          !UserData.user.previews.containsKey(SettingsData.appCollection);
      return FirestoreClient()
          .updateFieldInsideBusinessAndPreview(
              businessDocFieldName: 'shopName',
              previewsFieldName: 'name',
              isExistInPreviews: isExistInPreviews,
              userPhone: UserData.user.phoneNumber,
              businessId: SettingsData.appCollection,
              value: name)
          .then((value) async {
        if (value) {
          SettingsData.settings.shopName = name;
          if (isExistInPreviews) {
            final buisnessesPreviews =
                SettingsData.buisnessesPreview.buisnesses;
            if (buisnessesPreviews.containsKey(SettingsData.appCollection)) {
              buisnessesPreviews[SettingsData.appCollection]!.name = name;
            }
          } else {
            if (UserData.user.previews.containsKey(SettingsData.appCollection))
              UserData.user.previews[SettingsData.appCollection]!.name = name;
          }
        }
        return value;
      });
    }
    AppErrors.error = Errors.emptyField;
    return false;
  }

  Future<bool> updateShopPhone(String phone) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateShopPhone]);
    if (phone != SettingsData.settings.shopPhone) {
      return await FirestoreClient()
          .updateFieldInsideDocAsMap(
              fieldName: 'shopPhone',
              docId: GeneralData.currentBusinesssId,
              path: buisnessCollection,
              value: phone)
          .then((value) {
        if (value) SettingsData.settings.shopPhone = phone;
        return value;
      });
    }
    logger.d("Same shop phone nothing changes");
    return true;
    //AppErrors.error = Errors.illegalFields;
    //return false;
  }

  Future<bool> updateAddress(String newAdress) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateAddress]);
    final isExistInPreviews =
        !UserData.user.previews.containsKey(SettingsData.appCollection);
    return await FirestoreClient()
        .updateFieldInsideBusinessAndPreview(
            businessDocFieldName: 'adress',
            previewsFieldName: 'address',
            isExistInPreviews: isExistInPreviews,
            userPhone: UserData.user.phoneNumber,
            businessId: SettingsData.appCollection,
            value: newAdress)
        .then((value) async {
      if (value) {
        SettingsData.settings.adress = newAdress;
        if (isExistInPreviews) {
          final buisnessesPreviews = SettingsData.buisnessesPreview.buisnesses;
          if (buisnessesPreviews.containsKey(SettingsData.appCollection)) {
            buisnessesPreviews[SettingsData.appCollection]!.address = newAdress;
          }
        } else {
          if (UserData.user.previews.containsKey(SettingsData.appCollection))
            UserData.user.previews[SettingsData.appCollection]!.address =
                newAdress;
        }
      }
      return value;
    });
  }

  Future<bool> updateBusinessType(BusinessesTypes businessType) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateBusinessType]);
    final isExistInPreviews =
        !UserData.user.previews.containsKey(SettingsData.appCollection);
    return await FirestoreClient()
        .updateFieldInsideBusinessAndPreview(
            businessDocFieldName: 'businesseType',
            previewsFieldName: 'businesseType',
            isExistInPreviews: isExistInPreviews,
            userPhone: UserData.user.phoneNumber,
            businessId: SettingsData.appCollection,
            value: businessTypeToStr[businessType])
        .then((value) async {
      if (value) {
        SettingsData.settings.businesseType = businessType;
        if (isExistInPreviews) {
          final buisnessesPreviews = SettingsData.buisnessesPreview.buisnesses;
          if (buisnessesPreviews.containsKey(SettingsData.appCollection)) {
            buisnessesPreviews[SettingsData.appCollection]!.businesseType =
                businessType;
          }
        } else {
          if (UserData.user.previews.containsKey(SettingsData.appCollection)) {
            UserData.user.previews[SettingsData.appCollection]!.businesseType =
                businessType;
          }
        }
      }
      return value;
    });
  }

  Future<bool> updateInstagramAccount(String account) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateInstagramAccount]);
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
            fieldName: 'instagramAccount',
            docId: GeneralData.currentBusinesssId,
            path: buisnessCollection,
            value: account)
        .then((value) {
      if (value) SettingsData.settings.instagramAccount = account;
      return value;
    });
  }

  Future<bool> addUpdate(Update update, BuildContext context) async {
    AppErrors.addError(code: settingsCodeToInt[SettingsErrorCodes.addUpdate]);
    if (update.isValid()) {
      SettingsData.settings.updates.add(update);
      UiManager.insertUpdate(Providers.settings);
      UiManager.updateUi(context: context);
      return await FirestoreClient().updateFieldInsideDocAsArray(
          fieldName: 'updates',
          docId: GeneralData.currentBusinesssId,
          path: buisnessCollection,
          value: update.toJson(),
          command: ArrayCommands.add);
    }
    AppErrors.error = Errors.emptyField;
    return false;
  }

  Future<bool> replaceUpdate(
      Update oldUpdate, Update newUpdate, BuildContext context) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.replaceUpdate]);
    if (newUpdate.isValid()) {
      SettingsData.settings.updates.remove(oldUpdate);
      SettingsData.settings.updates.add(newUpdate);
      UiManager.insertUpdate(Providers.settings);
      UiManager.updateUi(context: context);

      final updatesJson = [];
      SettingsData.settings.updates.forEach((update) {
        updatesJson.add(update.toJson());
      });
      return await FirestoreClient().updateFieldInsideDocAsMap(
          fieldName: 'updates',
          docId: SettingsData.appCollection,
          path: buisnessCollection,
          value: updatesJson);
    }
    AppErrors.error = Errors.emptyField;
    return false;
  }

  Future<bool> deleteUpdate(Update update, BuildContext context) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.deleteUpdate]);

    if (SettingsData.settings.updates.contains(update)) {
      SettingsData.settings.updates.remove(update);
      UiManager.insertUpdate(Providers.settings);
      UiManager.updateUi(context: context);
      return await FirestoreClient()
          .updateFieldInsideDocAsArray(
              fieldName: 'updates',
              docId: GeneralData.currentBusinesssId,
              path: buisnessCollection,
              value: update.toJson(),
              command: ArrayCommands.remove)
          .then((value) {
        if (value) {}
        return value;
      });
    }
    AppErrors.error = Errors.alreadyExistItem;
    return false;
  }

  Future<bool> updateCurrency(CurrencyModel currency) async {
    AppErrors.addError(
        code: settingsCodeToInt[SettingsErrorCodes.updateCurrency]);
    return await FirestoreClient()
        .updateFieldInsideDocAsMap(
            fieldName: 'currency',
            docId: GeneralData.currentBusinesssId,
            path: buisnessCollection,
            value: currency.toJson())
        .then((value) {
      if (value) SettingsData.settings.currency = currency;
      return value;
    });
  }

  void addWorker(String userPhone, String userName) {
    AppErrors.addError(code: settingsCodeToInt[SettingsErrorCodes.addWorker]);
    /*Need another bookingsObjects map for not using 
      the const map in the constructor*/
    SettingsData.workers[userPhone] =
        (WorkerModel(phone: userPhone, name: userName, bookingObjects: {}));
    BookingProvider.workers[userPhone] =
        (WorkerModel(phone: userPhone, name: userName, bookingObjects: {}));

    UiManager.insertUpdate(Providers.settings);
  }

  void updateScreen() => notifyListeners();
}
