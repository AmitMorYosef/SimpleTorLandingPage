import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  Future<void> writeSecureData(String key, String value) async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  Future<String> readSecureData(String key) async {
    var readData = await _storage.read(key: key) ?? '';
    return readData;
  }

  Future<void> deleteSecureData(String key) async {
    var deleteData = await _storage.delete(key: key);
    return deleteData;
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
