import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../app_const/application_general.dart';

class LocalFileDb {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile({required String fileName}) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<Map<String, dynamic>?> readFromFile({required String fileName}) async {
    final file = await _localFile(fileName: fileName);
    // Read from file
    try {
      final result = await file.readAsString();
      return jsonDecode(result);
    } catch (e) {
      logger.e("Error while read from local file --> $e");
      return null;
    }
  }

  Future<bool> writeToFile(
      {required String fileName, required String content}) async {
    final file = await _localFile(fileName: fileName);
    // Write the file
    try {
      file.writeAsString(content);
      return true;
    } catch (e) {
      logger.e("Error while write to loacl file --> $e");
      return false;
    }
  }
}
