import 'dart:math';

import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../app_const/limitations.dart';
import '../app_statics.dart/settings_data.dart';
import '../app_statics.dart/user_data.dart';
import '../models/preview_model.dart';

String adressValidation(String text) {
  if (text.length > adressCharsLimit)
    return translate("addressValidation") +
        adressCharsLimit.toString() +
        translate("chars");
  else
    return '';
}

String instagramValidation(String text) {
  if (text.length > instagramCharsLimit)
    return translate("instagramValidation") +
        instagramCharsLimit.toString() +
        translate("chars");
  else
    return '';
}

String phoneValidation(String phone) {
  if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return translate("illegalNumber");
  if (phone.length != 10) return translate("illegalNumber");
  if (phone.substring(0, 2) != '05') return translate("illegalNumber");
  return '';
}

String deleteBusinessPhoneValidation(String phone) {
  if (phone != SettingsData.settings.shopPhone)
    return translate('noMatchPhoneNumbers');
  return phoneValidation(phone);
}

String deleteUserPhoneValidation(String phone) {
  if (phone != UserData.user.phoneNumber)
    return translate('noMatchPhoneNumbers');
  return phoneValidation(phone);
}

String logginPhoneValidation(String phone) {
  if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return translate("illegalNumber");
  if (phone.length != 10 && phone.length != 9)
    return translate("illegalNumber");
  if ((phone.substring(0, 2) != '05' && phone.length == 10) ||
      (phone.substring(0, 1) != '5' && phone.length == 9))
    return translate("illegalNumber");
  return '';
}

String timeValidation(String time) {
  try {
    if (!time.endsWith('0') && !time.endsWith('5'))
      return translate("timeNeedToEndWth0or5");
    return '';
  } catch (e) {
    return translate("illegalDuration");
  }
}

String treatmentDurationValidation(
  String duration,
) {
  if (duration == '') return translate("illegalDuration");
  if (double.tryParse(duration) == null) ;
  if (double.tryParse(duration) == 0)
    return translate("durationMustBeGratherThenZero");
  if (duration.length > treatmentDurationCharsLimit)
    return translate("durationToLong");
  if (!duration.endsWith('0') && !duration.endsWith('5'))
    return translate("timeNeedToEndWth0or5");
  return '';
}

String shopNameValidation(String shopName) {
  if (shopName.contains("~")) return translate("illegalName");
  if (shopName.length > shopNameCharsLimit)
    return translate("buisnessNameCrossedLimit") +
        shopNameCharsLimit.toString() +
        translate("chars");
  if (shopName.length == 0) return translate("buisnessNameMustBeSometing");
  // business name already exist
  final buisnesses = SettingsData.buisnessesPreview.buisnesses;
  for (Preview businessPreview in buisnesses.values)
    if (businessPreview.name == shopName)
      return translate("thereIsBusinessNameAlready");
  return '';
}

String updateContentValidation(String text) {
  if (text.trim().length == 0) return translate("mustIncluteChars");
  if (text.length > updateContentCharsLimit)
    return translate("contentIsTill") +
        " " +
        updateContentCharsLimit.toString() +
        " " +
        translate("chars");
  else
    return '';
}

String updateTitleValidation(String text) {
  if (text.trim().length == 0) return translate("mustIncluteChars");
  if (text.length > updateTitleCharsLimit)
    return translate("titleIsTill") +
        " " +
        updateTitleCharsLimit.toString() +
        " " +
        translate("chars");
  else
    return '';
}

String nameValidation(String name) {
  if (name.contains("~")) return translate("illegalName");
  if (name == "guest") return translate("illegalName");
  if (name.length > 15 || name.length < 2) return translate("illegalName");
  if (name.length > 8 && !name.contains(" ")) return translate("illegalName");
  for (var i = 0; i < min(name.length, 2); i++) {
    if (name[i] == " ") return translate("illegalName");
  }
  return '';
}

String priceValidation(String price) {
  if (price.length > 6) return translate("priceLimit");
  try {
    double.parse(price);
    return '';
  } catch (e) {
    return translate("illegalPrice");
  }
}

String treatmentNameValidation(String name) {
  if (name.trim().length > treatmentNameCharsLimit)
    return translate("toLongName");
  if (name.trim().length == 0)
    return translate("mustIncluteChars");
  else
    return '';
}

String breakNameValidation(String name) {
  if (name.trim().length > breakNameCharsLimit)
    return translate("toLongName");
  else
    return '';
}

String noteValidation(String note) {
  if (note.trim().length > noteCharLimit)
    return translate("tooLongNote");
  else
    return '';
}

String durationValidation(String duration) {
  if (double.tryParse(duration) != null) return '';
  return translate("illegalDuration");
}

String notificationMassageValidation(String massage) {
  if (massage.length < 5) return translate("shortMassage");
  return "";
}

String productNameValidation(String name) {
  if (name.trim().length > productNameCharsLimit)
    return translate("toLongName");
  if (name.trim().length == 0)
    return translate("mustIncluteChars");
  else
    return '';
}

String productDecriptionValidation(String name) {
  if (name.trim().length > productDescriptionCharsLimit)
    return translate("toLongName");
  if (name.trim().length == 0)
    return translate("mustIncluteChars");
  else
    return '';
}
