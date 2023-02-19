import 'package:firebase_database/firebase_database.dart';

import '../../app_const/db.dart';
import '../external_services/real_time_database.dart';

class FirebaseRealTimeClient {
  static final FirebaseRealTimeClient _singleton =
      FirebaseRealTimeClient._internal();

  FirebaseRealTimeClient._internal();

  factory FirebaseRealTimeClient() {
    FirebaseRealTimeClient object = _singleton;
    return object;
  }

  final RealTimeDatabase realTimeDatabase = RealTimeDatabase();

  Future<bool> updateChild({
    required String pathToChild,
    required dynamic data,
  }) async {
    return await realTimeDatabase.updateChild(
        childPath: pathToChild, data: data);
  }

  Future<bool> removeChild({required String pathToChild}) async {
    return await realTimeDatabase.removeChild(childPath: pathToChild);
  }

  Future<DataSnapshot> getChild({required String pathToChild}) async {
    return await realTimeDatabase.getChild(childPath: pathToChild);
  }

  Stream<DatabaseEvent> getListenerToChild({required String pathToChild}) {
    return realTimeDatabase.listenToChild(childPath: pathToChild);
  }

  Future<bool> updateNumberChild(
      {required String pathToChild,
      required String valueId,
      required int delta,
      required NumericCommands command}) async {
    if (command == NumericCommands.decrement) {
      delta = -delta;
    }
    return await realTimeDatabase.incrementNumberChild(
      childPath: pathToChild,
      valueId: valueId,
      delta: delta,
    );
  }
}
