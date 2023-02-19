import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_tor_web/services/errors_service/app_errors.dart';
import 'package:simple_tor_web/services/errors_service/messages.dart';

import '../../../app_const/application_general.dart';
import '../../../app_const/db.dart';

const TRANSACTION_TIME_OUT = Duration(seconds: 15);
const TRANSACTION_MAX_ATTEMPTS = 5;

class FirestoreDataBase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  WriteBatch get batch => _db.batch();

  void useEmulator() async {
    _db.useFirestoreEmulator("http://127.0.0.1/", 8080);
  }

  Future<bool> commmitBatch({required WriteBatch batch}) async {
    try {
      bool resp = false;
      await batch.commit().whenComplete(() => resp = true);
      return resp;
    } catch (e) {
      logger.e("Error while commit batch --> $e");
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      return false;
    }
  }

  Future<bool> runTransaction(
      {required Future<dynamic> Function(Transaction) transacionCommands,
      Duration timeout = TRANSACTION_TIME_OUT,
      int maxAttempts = TRANSACTION_MAX_ATTEMPTS}) async {
    try {
      return await _db.runTransaction((transaction) async {
        return await transacionCommands(transaction);
      }, timeout: timeout, maxAttempts: maxAttempts).then(
        (value) => value,
        onError: (e) {
          AppErrors.addError(error: Errors.serverError, details: e.toString());
          return false;
        },
      );
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      return false;
    }
  }

  Future<DocumentSnapshot<dynamic>> transactionGet(
      {required Transaction transaction,
      required String path,
      required String docId}) async {
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      return await transaction.get(ref);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void transactionUpdateAsMap({
    required Transaction transaction,
    required String path,
    required String docId,
    required String fieldName,
    dynamic value,
  }) async {
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      transaction.update(ref, {fieldName: value ?? FieldValue.delete()});
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void transactionUpdateMultipleFieldsAsMap({
    required Transaction transaction,
    required String path,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      Map<String, dynamic> organizedData = {};
      data.forEach((fieldName, value) {
        dynamic organizedValue = value;
        if (organizedValue == null) organizedValue = FieldValue.delete();
        if (organizedValue == NumericCommands.increment)
          organizedValue = FieldValue.increment(1);
        if (organizedValue == NumericCommands.decrement)
          organizedValue = FieldValue.increment(-1);
        organizedData[fieldName] = organizedValue;
      });

      final ref = _db.collection('$envKey/$path').doc(docId);
      transaction.update(ref, organizedData);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void transactionCreateDoc({
    required Transaction transaction,
    required String path,
    required String docId,
    dynamic value,
  }) async {
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      transaction.set(ref, value);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void transactionSetAsMap({
    required Transaction transaction,
    required String path,
    required String docId,
    required String fieldName,
    dynamic value,
  }) async {
    /* creat doc if dosen't exist */
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      transaction.set(ref, {fieldName: value ?? FieldValue.delete()},
          SetOptions(merge: true));
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void createDoc(
      {required WriteBatch batch,
      required String path,
      required String docId,
      required valueAsJson,
      bool insideEnviroments = true}) {
    try {
      final ref =
          _db.collection(insideEnviroments ? '$envKey/$path' : path).doc(docId);
      batch.set(ref, valueAsJson);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void deleteDoc(
      {required WriteBatch batch,
      required String path,
      required String docId}) {
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      batch.delete(ref);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void updateFieldInsideDocAsMap({
    required WriteBatch batch,
    required String path,
    required String docId,
    required String fieldName,
    bool insideEnviroments = true,
    NumericCommands? command,
    dynamic value,
  }) {
    try {
      final ref =
          _db.collection(insideEnviroments ? '$envKey/$path' : path).doc(docId);
      if (command == null) {
        batch.update(ref, {fieldName: value ?? FieldValue.delete()});
      } else {
        batch.update(ref, {
          fieldName: command == NumericCommands.increment
              ? FieldValue.increment(1)
              : FieldValue.increment(-1)
        });
      }
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void updateMultipleFieldsInsideDocAsMap({
    required WriteBatch batch,
    required String path,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    try {
      Map<String, dynamic> organizedData = {};
      data.forEach((fieldName, value) {
        dynamic organizedValue = value;
        if (organizedValue == null) organizedValue = FieldValue.delete();
        if (organizedValue == NumericCommands.increment)
          organizedValue = FieldValue.increment(1);
        if (organizedValue == NumericCommands.decrement)
          organizedValue = FieldValue.increment(-1);
        organizedData[fieldName] = organizedValue;
      });

      final ref = _db.collection('$envKey/$path').doc(docId);
      batch.update(ref, organizedData);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void updateFieldInsideDocAsArray(
      {required WriteBatch batch,
      required String path,
      required String docId,
      required String fieldName,
      required dynamic value,
      ArrayCommands command = ArrayCommands.add}) {
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      batch.update(ref, {
        fieldName: command == ArrayCommands.remove
            ? FieldValue.arrayRemove([value])
            : FieldValue.arrayUnion([value])
      });
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void updateMultipleFieldsInsideDocAsArray({
    required WriteBatch batch,
    required String path,
    required String docId,
    required dynamic data,
  }) {
    try {
      Map<String, dynamic> organizedData = {};
      data.forEach((fieldName, valueData) {
        final command = valueData["command"];
        final value = valueData["value"];

        organizedData[fieldName] = command == ArrayCommands.remove
            ? FieldValue.arrayRemove([value])
            : FieldValue.arrayUnion([value]);
      });

      final ref = _db.collection('$envKey/$path').doc(docId);
      batch.update(ref, organizedData);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  void setDoc(
      {required WriteBatch batch,
      required String path,
      required String docId,
      required valueToSet,
      bool insideEnviroments = true}) {
    try {
      final ref =
          _db.collection(insideEnviroments ? '$envKey/$path' : path).doc(docId);
      batch.set(ref, valueToSet as Map<String, dynamic>);
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
      {required String path,
      required String docId,
      bool insideEnviroments = true}) async {
    try {
      final ref =
          _db.collection(insideEnviroments ? '$envKey/$path' : path).doc(docId);
      return (await ref.get());
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocsWithQueries(
      {required String path,
      required Map<String, Map<QueryCommands, dynamic>> queryMap,
      bool insideEnviroments = true}) async {
    try {
      Query<Map<String, dynamic>> ref =
          _db.collection(insideEnviroments ? '$envKey/$path' : path);

      queryMap.forEach((fieldName, query) {
        ref = ref.where(
          fieldName.substring(0, fieldName.length - 1),
          isGreaterThanOrEqualTo:
              query.keys.first == QueryCommands.isGreaterThanOrEqualTo
                  ? query.values.first
                  : null,
          isEqualTo: query.keys.first == QueryCommands.isEqualTo
              ? query.values.first
              : null,
          isNotEqualTo: query.keys.first == QueryCommands.isNotEqualTo
              ? query.values.first
              : null,
          isLessThan: query.keys.first == QueryCommands.isLessThan
              ? query.values.first
              : null,
          isGreaterThan: query.keys.first == QueryCommands.isGreaterThan
              ? query.values.first
              : null,
          isLessThanOrEqualTo:
              query.keys.first == QueryCommands.isLessThanOrEqualTo
                  ? query.values.first
                  : null,
          arrayContains: query.keys.first == QueryCommands.arrayContains
              ? query.values.first
              : null,
          arrayContainsAny: query.keys.first == QueryCommands.arrayContainsAny
              ? query.values.first
              : null,
          whereIn: query.keys.first == QueryCommands.whereIn
              ? query.values.first
              : null,
          whereNotIn: query.keys.first == QueryCommands.whereNotIn
              ? query.values.first
              : null,
          isNull: query.keys.first == QueryCommands.isNull
              ? query.values.first
              : null,
        );
      });

      return await ref.get();
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> docListener(
      {required String path, required String docId}) {
    try {
      final ref = _db.collection('$envKey/$path').doc(docId);
      return ref.snapshots();
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDocsInsideCollection({
    required String path,
  }) async {
    try {
      final ref = _db.collection('$envKey/$path');
      final docs = await ref.get();
      return docs.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }

  Future<List<String>> getAllDocIdsInsideCollection({
    required String path,
  }) async {
    try {
      final ref = _db.collection('$envKey/$path');
      final docs = await ref.get();
      return docs.docs.map((doc) => doc.id).toList();
    } catch (e) {
      AppErrors.addError(error: Errors.serverError, details: e.toString());
      rethrow;
    }
  }
}
