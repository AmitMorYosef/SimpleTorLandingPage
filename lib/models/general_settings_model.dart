import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_tor_web/models/product_model.dart';
import 'package:simple_tor_web/models/update_model.dart';

import '../app_const/business_types.dart';
import '../app_const/display.dart';
import '../app_const/purchases.dart';
import 'currency_model.dart';

class GeneralSettingsModel {
  BusinessesTypes businesseType = BusinessesTypes.other;
  int changingImagesSwapSeconds = 6;
  late CurrencyModel currency;
  bool notifyOnNewCustomer = false;
  String shopPhone = "",
      ownersName = "",
      ownersPhone = "",
      previewDoc = "",
      shopName = "",
      shopIconUrl = "",
      instagramAccount = "",
      revenueCatId = "",
      pendingWorkersProductsId = "",
      adress = "",
      workersProductsId = "",
      pendingProductId = "",
      fontName = "",
      storyTitle = "",
      productId = "";

  Themes? theme;

  DateTime createdAt = DateTime.now();

  List<String> changingImages = [];
  Map<String, ProductModel> products = {};
  List<Update> updates = [];
  Map<String, String> blockedUsers = {};
  Map<BuisnessLimitations, int> limits = {
    BuisnessLimitations.bookingCount: 4,
    BuisnessLimitations.changingPhotos: 3,
    BuisnessLimitations.storyPhotos: 5,
    BuisnessLimitations.products: 5,
    BuisnessLimitations.expiredDataDeleteHeighsetDays: 32,
    BuisnessLimitations.expiredDataDeleteLowestDays: 7
  };

  GeneralSettingsModel(
      {required this.shopName,
      required this.currency,
      required this.productId,
      required this.adress,
      required this.revenueCatId,
      required this.ownersName,
      required this.businesseType,
      required this.instagramAccount,
      required this.shopPhone,
      this.changingImagesSwapSeconds = 6,
      required this.theme});

  GeneralSettingsModel.empty();

  GeneralSettingsModel.fromJson(json) {
    theme = themeFromStr[json['theme']]!;
    if (json["currency"] != null) {
      currency = CurrencyModel.from(json: json["currency"]);
    }
    previewDoc = json['previewDoc'];
    workersProductsId = json['workersProductsId'] ?? "";
    pendingWorkersProductsId = json["pendingWorkersProductsId"] ?? "";
    shopName = json["shopName"];
    notifyOnNewCustomer = json["notifyOnNewCustomer"] ?? true;
    if (json["blockedUsers"] != null) {
      json["blockedUsers"].forEach((userId, details) {
        blockedUsers[userId] = details;
      });
    }
    fontName = json["fontName"] ?? "";
    ownersName = json['ownersName'] ?? "";
    revenueCatId = json['revenueCatId'] ?? "";
    productId = json['productId'] ?? "";
    pendingProductId = json["pendingProductId"] ?? "";
    changingImagesSwapSeconds = json['changingImagesSwapSeconds'] ?? 6;
    businesseType =
        businessTypeFromStr[json['businesseType']] ?? BusinessesTypes.other;
    shopIconUrl = json["shopIcon"];
    instagramAccount = json["instagramAccount"];
    adress = json["adress"];
    shopPhone = json["shopPhone"];

    if (createdAt is Timestamp) {
      createdAt = (json["createdAt"] as Timestamp).toDate();
    } else if (createdAt is String) {
      createdAt = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    }
    json["limits"].forEach((key, val) {
      if (limitationFromStr[key] != null) limits[limitationFromStr[key]!] = val;
    });
    limits[BuisnessLimitations.products] =
        limits[BuisnessLimitations.products] ?? 5;
    json["products"].forEach((productId, product) {
      products[productId] = ProductModel.fromJson(product);
    });
    changingImages =
        json["changingImages"].map<String>((item) => item as String).toList();

    json["updates"].forEach((value) {
      updates.add(Update.fromJson(value));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data["theme"] = themeToStr[theme];
    data["notifyOnNewCustomer"] = notifyOnNewCustomer;
    data["currency"] = currency.toJson();
    data["changingImagesSwapSeconds"] = changingImagesSwapSeconds;
    data["workersProductsId"] = workersProductsId;
    data["pendingWorkersProductsId"] = pendingWorkersProductsId;
    data["blockedUsers"] = blockedUsers;
    data["previewDoc"] = previewDoc;
    data["revenueCatId"] = revenueCatId;
    data["pendingProductId"] = pendingProductId;
    data["productId"] = productId;
    data["shopName"] = shopName;
    data["fontName"] = fontName;
    data["shopIcon"] = shopIconUrl;
    data['businesseType'] = businessTypeToStr[this.businesseType]!;
    data["ownersName"] = ownersName;
    data["instagramAccount"] = instagramAccount;
    data["adress"] = adress;
    data["shopPhone"] = shopPhone;
    data["changingImages"] = changingImages;

    data["products"] = {};
    products.forEach((key, product) {
      data["products"][key] = product.toJson();
    });
    data["updates"] = [];
    updates.forEach((update) {
      data["updates"].add(update.toJson());
    });
    data["createdAt"] = Timestamp.fromDate(createdAt);
    data["limits"] = {};
    limits.forEach((key, val) {
      data["limits"][limitationToStr[key]] = val;
    });
    data["updates"] = updates;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
