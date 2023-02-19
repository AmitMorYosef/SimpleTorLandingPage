import 'package:intl/intl.dart';
import 'package:simple_tor_web/models/worker_model.dart';

import '../../app_const/db.dart';
import '../../app_statics.dart/general_data.dart';
import '../../app_statics.dart/user_data.dart';
import '../booking_provider.dart';

class DbPathesHelper {
  /// Get: `workerPhone`  return path to his likes child in realTime db
  String getLisksChildPath(String workerPhone) {
    String pathToWorkers =
        '$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection';
    String pathToLiks = '${workerPhone}/$likesCollection';
    return '$pathToWorkers/$pathToLiks';
  }

  /// Get: `workerPhone`  return path to his waitingList child in realTime db
  String getWaitingListChildPath() {
    String day =
        DateFormat('dd-MM-yy').format(BookingProvider.booking.bookingDate);
    String pathToWorkers =
        '$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection';
    String pathToToday =
        '${BookingProvider.workerPhone}/$waitingListCollection/$day';
    return '$pathToWorkers/$pathToToday/${UserData.user.phoneNumber}';
  }

  /// Get: `worker`
  /// return the path of all his waitingList "child parent" in realTime db
  String getAllWaitingListsChildPath(WorkerModel worker) {
    String pathToWorkers =
        '$buisnessCollection/${GeneralData.currentBusinesssId}/$workersCollection';
    return '$pathToWorkers/${worker.phone}/$waitingListCollection';
  }

  /// Get: image_type and return the name of the image in cloud storage
  /// Example - imageType: "story_images", imageUrl: "https://...bdsb.b..n."
  String getImageStorageName(String imageType, String imageUrl) {
    final nameForPath = imageType.toUpperCase();
    List<String> url_subs = imageUrl.split(nameForPath);
    return "$nameForPath${url_subs[1].split('.jpg')[0]}";
  }

  /// Get: workerPhone, businessId and imageId return the path to image
  /// likes path of realTimeDataBase
  /// Example - workerPhone: "+972-525656377", imageUrl: "972-525656377--jebjvjlbvkj..."
  /// ,imageId:"fnjkbfbjknkrfnkjf..."
  String getLikesChildPath(
      String workerPhone, String businessId, String imageId) {
    String pathToWorkers =
        '$buisnessCollection/${businessId}/$workersCollection';
    String pathToLikes = '${workerPhone}/$likesCollection';
    return '$pathToWorkers/$pathToLikes/$imageId';
  }
}
