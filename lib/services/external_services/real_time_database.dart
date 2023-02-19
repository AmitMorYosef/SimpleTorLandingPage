import 'package:firebase_database/firebase_database.dart';

import '../../../app_const/application_general.dart';
import '../../../app_const/db.dart';
import '../errors_service/app_errors.dart';
import '../errors_service/messages.dart';

class RealTimeDatabase {
  final _db = FirebaseDatabase.instance.ref();

  Future<DataSnapshot> getChild({
    required String childPath,
  }) async {
    try {
      return await _db.child('$envKey/$childPath').get();
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Future<bool> updateChild(
      {required String childPath, required dynamic data}) async {
    try {
      await _db.child('$envKey/$childPath').update(data);
      return true;
    } catch (e) {
      logger.e("Errror while update the child --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      return false;
    }
  }

  Future<bool> removeChild({required String childPath}) async {
    try {
      await _db.child('$envKey/$childPath').remove();
      return true;
    } catch (e) {
      logger.e("Errror while removing the child --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      return false;
    }
  }

  Future<bool> incrementNumberChild(
      {required String childPath,
      required String valueId,
      required int delta}) async {
    try {
      Map<String, Object?> data = {valueId: ServerValue.increment(delta)};
      await _db.child('$envKey/$childPath').update(data);
      return true;
    } catch (e) {
      logger.e("Errror while update the child --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      return false;
    }
  }

  Stream<DatabaseEvent> listenToChild({required String childPath}) {
    return _db.child('$envKey/$childPath').onValue;
    // .listen((DatabaseEvent event) {
    //   final data = event.snapshot.value;
    //   updateStarCount(data);
    // });
  }

  Future<bool> setChild(
      {required String childPath, required dynamic data}) async {
    try {
      await _db.child('$envKey/$childPath').set(data);
      return true;
    } catch (e) {
      logger.e("Errror while update the child --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      return false;
    }
  }

  Stream<DatabaseEvent>? onChildAddedListener({required String childPath}) {
    try {
      return _db.child('$envKey/$childPath').onChildAdded;
    } catch (e) {
      logger.e("Errror while update the child --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Stream<DatabaseEvent>? onChildRemovedListener({required String childPath}) {
    try {
      return _db.child('$envKey/$childPath').onChildRemoved;
    } catch (e) {
      logger.e("Errror while update the child --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  // Future<TransactionResult> runTransaction({required String childPath}) {
  //   return _db.child('$envKey/$childPath').runTransaction((post) {
  //      // Ensure a post at the ref exists.
  //   if (post == null) {
  //     return Transaction.abort();
  //   }

  //   // Return the new data.
  //   return Transaction.success(_post);
  //   });
  // }
}
