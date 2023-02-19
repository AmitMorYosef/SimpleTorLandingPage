import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../app_const/application_general.dart';
import '../../app_const/db.dart';
import '../../app_statics.dart/general_data.dart';
import '../errors_service/app_errors.dart';
import '../errors_service/messages.dart';
import '../external_services/firebase_storage.dart';
import '../external_services/firestore.dart';

class FirebaseStorageClient {
  static final FirebaseStorageClient _singleton =
      FirebaseStorageClient._internal();

  FirebaseStorageClient._internal();

  factory FirebaseStorageClient() {
    FirebaseStorageClient object = _singleton;
    return object;
  }

  final StorageDb firebaseStorage = StorageDb();
  final FirestoreDataBase firestoreDataBase = FirestoreDataBase();
  Uuid uuid = const Uuid();

  Future<String> uploadImage({
    required XFile image,
    required String imageType,
    required String storagePath,
    required String dbDoc,
    required String dbCollection,
    bool updateDb = true,
  }) async {
    //"story_Images"
    final batch = firestoreDataBase.batch;
    final nameForPath = imageType.toUpperCase();
    File? file = File(image.path);
    final imageId = uuid.v1();
    String imageUrl = '';
    await firebaseStorage
        .uploadFile(
            file: file, fileName: "$nameForPath$imageId", path: storagePath)
        .then((path) async {
      if (path == '') {
        /*Cant upload to the storage*/
        return;
      }
      imageUrl = path;
      if (updateDb) {
        firestoreDataBase.updateFieldInsideDocAsMap(
            batch: batch,
            docId: dbDoc,
            path: dbCollection,
            value: path,
            fieldName: imageType.replaceAll("_", ""));

        await firestoreDataBase.commmitBatch(batch: batch);
      }
    });
    return imageUrl;
  }

  Future<bool> deleteImage(
      {required String imageUrl,
      required String imageType,
      required String dbPath,
      bool isExistInPreviews = true,
      required String dbDocId,
      required String userPhone,
      required String storagePath,
      required String dbFieldName,
      String? dbValue = null,
      bool inArray = true,
      String changeInPreview = "",
      bool updateDb = true}) async {
    final batch = firestoreDataBase.batch;
    final nameForPath = imageType.toUpperCase();
    List<String> url_subs = imageUrl.split(nameForPath);
    String imageName = "$nameForPath${url_subs[1].split('.jpg')[0]}";
    if (updateDb) {
      if (changeInPreview != "") {
        if (isExistInPreviews) {
          firestoreDataBase.updateFieldInsideDocAsMap(
              batch: batch,
              path: buisnessesPreviewCollection,
              docId: previewDoc,
              fieldName: changeInPreview,
              value: "");
        } else {
          firestoreDataBase.updateFieldInsideDocAsMap(
              batch: batch,
              path: usersCollection,
              docId: userPhone,
              fieldName: changeInPreview,
              value: "");
        }
      }
      inArray
          ? firestoreDataBase.updateFieldInsideDocAsArray(
              batch: batch,
              docId: dbDocId,
              path: dbPath,
              fieldName: dbFieldName,
              value: imageUrl,
              command: ArrayCommands.remove)
          : firestoreDataBase.updateFieldInsideDocAsMap(
              batch: batch,
              docId: dbDocId,
              path: dbPath,
              fieldName: dbFieldName,
              value: dbValue);
    }
    bool dbUpdated = true;
    if (updateDb)
      dbUpdated = await firestoreDataBase.commmitBatch(batch: batch);
    if (!dbUpdated) return false;
    return firebaseStorage.deleteFile(fileName: imageName, path: storagePath);
  }

  Future<List<String>> uploadMultipleImages({
    required List<XFile> images,
    required String imageType,
    String? workerPhone = null,
  }) async {
    //"story_Images"
    final batch = firestoreDataBase.batch;
    final nameForPath = imageType.toUpperCase();

    List<String> imageUrls = [];
    await Future.wait(images.map((image) async {
      File? file = File(image.path);
      final imageId = uuid.v1();
      await firebaseStorage
          .uploadFile(
              file: file,
              fileName: "$nameForPath$imageId",
              path: changingImagesPath)
          .then((path) async {
        if (path == '') return false;
        imageUrls.add(path);
        firestoreDataBase.updateFieldInsideDocAsArray(
            batch: batch,
            docId: GeneralData.currentBusinesssId,
            path: buisnessCollection,
            value: path,
            fieldName: imageType.replaceAll("_", ""),
            command: ArrayCommands.add);
      }).then((value) => logger.i("Finish to upload image"));
    }).toList());
    await firestoreDataBase.commmitBatch(batch: batch);
    return imageUrls;
  }

  Future<Map<String, String>?> uploadStoryImages({
    required List<XFile> images,
    required String workerPhone,
  }) async {
    //"story_Images"
    final batch = firestoreDataBase.batch;
    final nameForPath = "STORY_IMAGES";
    Map<String, String> idsAndPaths = {};
    bool hasPermission = true;

    await Future.wait(images.map((image) async {
      File? file = File(image.path);
      final imageId = uuid.v1();
      if (!hasPermission) return;
      await firebaseStorage
          .uploadFile(
              file: file,
              fileName: "$nameForPath$imageId",
              path: storyImagesPath)
          .then((path) async {
        if (path == "") {
          hasPermission = false;
          return;
        }
        idsAndPaths[imageId] = path;
        firestoreDataBase.updateFieldInsideDocAsMap(
          batch: batch,
          docId: workerPhone,
          path:
              "$buisnessCollection/$GeneralData.currentBusinesssId/$workersCollection",
          value: path,
          fieldName: "storyImages.$imageId",
        );
      }).then((value) => logger.i("Finish to upload image"));
    }).toList());
    if (hasPermission) {
      await firestoreDataBase.commmitBatch(batch: batch);
    } else {
      AppErrors.addError(error: Errors.noPermission);
    }
    return hasPermission ? idsAndPaths : null;
  }

  Future<String> updateImage(
      { //ask
      required String imageType,
      required String currentUrl,
      required XFile image,
      required String storagePath}) async {
    //imageType need to be for example :"shopeIcon"
    final nameForPath = imageType.toUpperCase();
    List<String> url_subs = currentUrl.split(nameForPath);
    String imageName = "$nameForPath${url_subs[1].split('.jpg')[0]}";
    File? file = File(image.path);
    return await firebaseStorage.uploadFile(
        file: file, fileName: imageName, path: storagePath);
  }
}
