import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_tor_web/models/notification_topic.dart';
import 'package:simple_tor_web/models/preview_model.dart';

import '../app_const/gender.dart';
import '../app_const/limitations.dart';
import '../app_const/notification.dart';
import 'booking_model.dart';

class User {
  late String name = "";
  late String phoneNumber = "";
  late Map<String, Map<String, dynamic>> productsIds = {};
  late Map<String, String> pendingProductsIds = {};
  late String currentFcm = '';
  late String revenueCatId = "";
  late int limitOfBuisnesses;
  Map<String, int> permission = {};
  late List<String> myBuisnessesIds = [];
  List<String> storyLikes = [];
  Gender gender = Gender.anonymous;
  Map<String, Booking> bookings = {};
  Map<String, Booking> passedBookings = {};
  Map<String, Preview> previews = {};
  List<String> lastVisitedBuisnesses = [];
  List<String> lastVisitedBuisnessesRemoved = [];
  Timestamp lastCleanDate = Timestamp.fromDate(DateTime.now());
  Map<NotifySorts, Map<String, String>> subToNotifications = {
    NotifySorts.waitingList: {}, // "unic notify (subTo)": "full nutify(db)"
    NotifySorts.buisness: {}, // "unic notify (subTo)": "full nutify(db)"
  };
  String anonymousDocId = '';
  DateTime createdAt = DateTime.now();

  User(
      {this.name = '',
      this.phoneNumber = '',
      required this.productsIds,
      required this.myBuisnessesIds,
      this.revenueCatId = "",
      this.limitOfBuisnesses = 1,
      this.anonymousDocId = '',
      this.gender = Gender.anonymous,
      required this.lastVisitedBuisnesses,
      required this.lastVisitedBuisnessesRemoved,
      this.subToNotifications = const {
        NotifySorts.waitingList: {},
        NotifySorts.buisness: {},
      },
      bookings,
      lastCleanDate,
      createdAt});

  User.fromUserDocJson(Map<String, dynamic> json) {
    /*This function will create new user from that json dont use it
     if you want to update the user it will not consider the user 
     publicData doc */

    name = json['name'];
    currentFcm = json["currentFcm"] ?? "";
    gender = genderFromStr[json['gender']]!;
    phoneNumber = json["phoneNumber"];

    if (json["storyLikes"] != null) {
      json["storyLikes"].forEach((imageId) => storyLikes.add(imageId));
    }
    productsIds = {};
    if (json['productsIds'] != null) {
      json['productsIds'].forEach(
          (productId, businessId) => productsIds[productId] = businessId);
    }
    if (json['pendingProductsIds'] != null) {
      json['pendingProductsIds'].forEach((productId, businessId) =>
          pendingProductsIds[productId] = businessId);
    }
    revenueCatId = json['revenueCatId'] ?? "";
    lastCleanDate = json['lastCleanDate'];

    json["lastVisitedBuisnesses"]
        .forEach((Id) => lastVisitedBuisnesses.add(Id));

    if (json["lastVisitedBuisnessesRemoved"] != null) {
      json["lastVisitedBuisnessesRemoved"]
          .forEach((Id) => lastVisitedBuisnessesRemoved.add(Id));
    }

    limitOfBuisnesses = json["limitOfBuisnesses"];
    json['subToNotifications'].forEach((key, val) {
      this.subToNotifications[notifySortsFromStr[key]!] = {};
      val as List<dynamic>;
      val.forEach((element) {
        NotificationTopic obj = NotificationTopic.fromTopicStr(element);
        this.subToNotifications[notifySortsFromStr[key]!]![obj.toTopicStr()] =
            element;
      });
    });

    if (json["previews"] != null) {
      json["previews"].forEach((businessId, previewJson) {
        previews[businessId] = Preview.fromJson(previewJson);
      });
    }
    createdAt = DateTime.parse(json['createdAt']);
  }

  void setUserDoc(Map<String, dynamic> json) {
    /*This func will insert the json data to the current user -
    need to use that when need to update the user and not 
    create new user*/

    name = json['name'];
    currentFcm = json["currentFcm"] ?? "";
    gender = genderFromStr[json['gender']]!;
    phoneNumber = json["phoneNumber"];
    storyLikes = [];
    storyLikes = json["storyLikes"] ?? [];
    productsIds = {};
    if (json['productsIds'] != null) {
      json['productsIds'].forEach(
          (productId, businessId) => productsIds[productId] = businessId);
    }
    pendingProductsIds = {};
    if (json['pendingProductsIds'] != null) {
      json['pendingProductsIds'].forEach((productId, businessId) =>
          pendingProductsIds[productId] = businessId);
    }
    revenueCatId = json['revenueCatId'] ?? "";
    lastCleanDate = json['lastCleanDate'];
    lastVisitedBuisnesses = [];
    json["lastVisitedBuisnesses"]
        .forEach((Id) => lastVisitedBuisnesses.add(Id));
    if (json["lastVisitedBuisnessesRemoved"] != null) {
      lastVisitedBuisnessesRemoved = [];
      json["lastVisitedBuisnessesRemoved"]
          .forEach((Id) => lastVisitedBuisnessesRemoved.add(Id));
    }
    limitOfBuisnesses = json["limitOfBuisnesses"];
    subToNotifications = {};
    json['subToNotifications'].forEach((key, val) {
      this.subToNotifications[notifySortsFromStr[key]!] = {};
      val as List<dynamic>;
      val.forEach((element) {
        NotificationTopic obj = NotificationTopic.fromTopicStr(element);
        this.subToNotifications[notifySortsFromStr[key]!]![obj.toTopicStr()] =
            element;
      });
    });
    previews = {};
    if (json["previews"] != null) {
      json["previews"].forEach((businessId, previewJson) {
        previews[businessId] = Preview.fromJson(previewJson);
      });
    }

    createdAt = DateTime.parse(json['createdAt']);
  }

  void setUserPublicData(Map<String, dynamic> dataJson) {
    /*set the public data doc of the user to the user object*/
    bookings = {};
    passedBookings = {};
    permission = {};
    myBuisnessesIds = [];

    name = dataJson['name'];
    currentFcm = dataJson["currentFcm"] ?? "";
    gender = genderFromStr[dataJson['gender']]!;
    phoneNumber = dataJson["phoneNumber"];
    if (dataJson["permission"] != null) {
      dataJson["permission"].forEach((businessId, codePermission) {
        if (codePermission == 2) myBuisnessesIds.add(businessId);
        permission[businessId] = codePermission;
      });
    }
    if (dataJson["bookings"] != null) {
      dataJson["bookings"].forEach((bookingId, bookingJson) {
        final bookingObj = Booking.fromJson(bookingJson);
        /*get rid of booking that exceeded the userBookingLifeTime*/
        if (bookingObj.bookingDate
            .add(userBookingLifeTime)
            .isAfter(DateTime.now())) {
          /* sort the booking to two part passed and not passed 
            give 2 minutes spare for saftey*/
          if (bookingObj.bookingDate
              .add(Duration(minutes: bookingObj.treatment.totalMinutes + 2))
              .isAfter(DateTime.now())) {
            bookings[bookingObj.bookingId] = bookingObj;
          } else {
            passedBookings[bookingObj.bookingId] = bookingObj;
          }
        }
      });
    }
  }

  Map<String, dynamic> toPublicDataJson() {
    final Map<String, dynamic> data = {};
    data["bookings"] = {};
    bookings.forEach((bookingId, booking) {
      data["bookings"][bookingId] = booking.toJson();
    });
    /* get also the passed bookings -  need to keep
       them for the user history */
    passedBookings.forEach((bookingId, booking) {
      data["bookings"][bookingId] = booking.toJson();
    });

    data["permission"] = {};
    permission.forEach((businessId, codePermission) {
      data["permission"][businessId] = codePermission;
    });
    data['name'] = name;
    data['currentFcm'] = currentFcm;
    data['gender'] = genderToStr[gender];
    data["phoneNumber"] = phoneNumber;
    return data;
  }

  Map<String, dynamic> toUserDocJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['currentFcm'] = currentFcm;
    data['gender'] = genderToStr[gender];
    data["phoneNumber"] = phoneNumber;
    data['revenueCatId'] = revenueCatId;
    data['productsIds'] = productsIds;
    data['pendingProductsIds'] = pendingProductsIds;
    data['lastCleanDate'] = lastCleanDate;
    data['limitOfBuisnesses'] = limitOfBuisnesses;
    data['lastVisitedBuisnesses'] = lastVisitedBuisnesses;
    data['lastVisitedBuisnessesRemoved'] = lastVisitedBuisnessesRemoved;
    data['storyLikes'] = storyLikes;

    data["previews"] = {};
    previews.forEach((businessId, previewJson) {
      data["previews"][businessId] = previewJson;
    });
    data['subToNotifications'] = {};
    subToNotifications.forEach((key, val) {
      data['subToNotifications'][notifySortsToStr[key]!] =
          this.subToNotifications[key]!.values.toList();
    });
    data['createdAt'] = createdAt.toIso8601String();
    return data;
  }

  @override
  String toString() {
    return toUserDocJson().toString() + toPublicDataJson().toString();
  }
}
