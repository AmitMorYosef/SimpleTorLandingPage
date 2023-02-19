import 'package:management_system_app/services/in_app_services.dart/secured_storage.dart';

import '../../app_const/application_general.dart';

class SecuredStorageClient {
  static final SecuredStorageClient _singleton =
      SecuredStorageClient._internal();
  final SecureStorage _storage = SecureStorage();
  SecuredStorageClient._internal();

  factory SecuredStorageClient() {
    SecuredStorageClient object = _singleton;
    return object;
  }

// device storage buisness
  Future<bool> updateKeyInDeviceStorage(
      {required String key, required String value}) async {
    bool resp = true;
    await _storage.writeSecureData(key, value).onError((error, stackTrace) {
      logger.e("It was an error while save the value -- > $error");
      resp = false;
    });
    return resp;
  }

  Future<String> readKeyInDeviceStorage({required String key}) async {
    String resp =
        await _storage.readSecureData(key).onError((error, stackTrace) {
      logger.e("It was an error while read the value -- > $error");
      return '';
    });
    return resp;
  }

  Future<void> deleteKeyInDeviceStorage({required String key}) async {
    await _storage.deleteSecureData(key).onError((error, stackTrace) {
      logger.e("It was an error while read the value -- > $error");
    });
  }

  Future<bool> deleteUserCache(String userPhone) async {
    bool resp = true;
    await _storage.clear().onError((error, stackTrace) {
      logger.e("It was an error while deleting the cache -- > $error");
      resp = false;
    });
    return resp;
  }
}
