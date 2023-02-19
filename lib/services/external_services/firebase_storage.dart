import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/services/errors_service/messages.dart';

import '../../app_const/db.dart';
import '../../app_statics.dart/general_data.dart';

class StorageDb {
  final storageRef = FirebaseStorage.instance.ref();

  Future<String> uploadFile(
      {required File file, required fileName, required path}) async {
    String image_path = "";
    // Create a reference to "mountains.jpg"
    final mountainsRef = storageRef.child(
        "$envKey/${GeneralData.currentBusinesssId}/$path/${fileName}.jpg");
    try {
      await mountainsRef.putFile(file);
      image_path = await mountainsRef.getDownloadURL();
      return image_path;
    } catch (e) {
      logger.e("Error while uploading the file the error is - $e");
      AppErrors.addError(error: Errors.storageError, details: e.toString());
      return '';
    }
  }

  Future<bool> deleteFile({required fileName, required path}) async {
    try {
      // Create a reference to the file to delete
      final desertRef = storageRef.child(
          "$envKey/${GeneralData.currentBusinesssId}/$path/${fileName}.jpg");
      // Delete the file
      await desertRef.delete();
      return true;
    } catch (e) {
      AppErrors.addError(error: Errors.storageError, details: e.toString());
      return false;
    }
  }

  Future<bool> deleteSetFromPathFiles(
      {required String path, required Set<String> imagesId}) async {
    try {
      // Create a reference to the file to delete
      ListResult directoriesRef =
          await storageRef.child("$envKey/$path").listAll();

      await Future.wait(directoriesRef.items.map((image) async {
        if (imagesId.contains(image.name)) {
          storageRef.child(image.fullPath).delete();
        }
      }).toList());
      return true;
    } catch (e) {
      AppErrors.addError(error: Errors.storageError, details: e.toString());
      return false;
    }
  }

  Future<bool> deleteAllFiles({required String path}) async {
    try {
      // Create a reference to the file to delete
      ListResult directoriesRef =
          await storageRef.child("$envKey/$path").listAll();
      await Future.wait(directoriesRef.prefixes.map((dir) async {
        ListResult images = await storageRef.child(dir.fullPath).listAll();
        await Future.wait(images.items.map((image) async {
          await storageRef.child(image.fullPath).delete();
        }).toList());
      }).toList());
      // Delete the file
      //await desertRef.delete();
      return true;
    } catch (e) {
      AppErrors.addError(error: Errors.storageError, details: e.toString());
      return false;
    }
  }
}
