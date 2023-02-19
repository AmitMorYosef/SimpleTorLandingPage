import 'package:simple_tor_web/app_const/business_types.dart';

import '../app_const/gender.dart';
import '../app_statics.dart/language_data.dart';
import '../app_statics.dart/user_data.dart';
import '../services/in_app_services.dart/language.dart';

String durationToString(Duration duration, {int shortTime = -1}) {
  String hours = '';
  String minutes = '';
  String days = '';
  if (duration.inDays == 1) days = translate("day");
  if (duration.inDays == 2) days = translate("twoDays");
  if (duration.inDays > 2) days = "${duration.inDays} " + translate("days");

  int hoursInt = duration.inHours - duration.inDays * 24;
  if (hoursInt == 1) hours = translate("hour");
  if (hoursInt > 1) hours = "$hoursInt" + translate("hoursChar");

  int minutesInt = duration.inMinutes - duration.inHours * 60;

  minutes = minutesInt > 0 ? "$minutesInt" + translate("minutesChar") : "";

  String text = '';

  if (duration.inDays == 365)
    text = translate("year");
  else if (minutes == '' && hours == '' && days != '')
    text = days;
  else if (minutes != '' && hours == '' && days == '')
    text = minutes;
  else if (minutes == '' && hours != '' && days == '')
    text = hours;
  else if (minutes != '' && hours != '' && days == '')
    text = hours + " " + translate("and") + minutes;
  else if (minutes != '' && hours == '' && days != '')
    text = days + " " + translate("and") + minutes;
  else if (minutes == '' && hours != '' && days != '')
    text = days + " " + translate("and") + hours;
  else if (minutes != '' && hours != '' && days != '')
    text = days + " ," + hours + " " + translate("and") + minutes;

  if (text.length == 0) return '';
  if (shortTime == -1) return text;
  if (shortTime > text.length) return text;
  return text.replaceRange(shortTime, null, '..');
}

String getUsablePhone(String phoneNumber) {
  return phoneNumber.replaceFirst('-', '');
}

String textAccordingToGender(String txt) {
  Gender userGender = UserData.user.gender;
  final isMale = (userGender == Gender.male || userGender == Gender.anonymous);
  if (!isMale) {
    maleToFemaleMap.keys.forEach((key) {
      txt = txt.replaceAll(key, maleToFemaleMap[key]!);
    });
  }
  return txt;
}

String translate(String strName, {bool needGender = true}) {
  String translatedStr = ApplicationLocalizations.translate(strName);
  if (LanguageData.currentLaguageCode == 'he' && needGender)
    return textAccordingToGender(translatedStr);
  return translatedStr;
}

String shortName(String longName) {
  return longName.split(" ")[0];
}

Map<String, BusinessesTypes> loadBusinessesTypesIntepeter() {
  return {
    translate("barber"): BusinessesTypes.barber,
    translate("polish"): BusinessesTypes.polish,
    translate("beautician"): BusinessesTypes.beautician,
    translate("manicurePedicure"): BusinessesTypes.manicurePedicure,
    translate("eyelashes"): BusinessesTypes.eyelashes,
    translate("eyebrows"): BusinessesTypes.eyebrows,
    translate("babysitter"): BusinessesTypes.babysitter,
    translate("reflexologist"): BusinessesTypes.reflexologist,
    translate("cobblers"): BusinessesTypes.cobblers,
    translate("clown"): BusinessesTypes.clown,
    translate("socialWorker"): BusinessesTypes.socialWorker,
    translate("magician"): BusinessesTypes.magician,
    translate("doctor"): BusinessesTypes.doctor,
    translate("veterinarian"): BusinessesTypes.veterinarian,
    translate("communicationTherapist"): BusinessesTypes.communicationTherapist,
    translate("dogGroomer"): BusinessesTypes.dogGroomer,
    translate("psychologist"): BusinessesTypes.psychologist,
    translate("physiotherapy"): BusinessesTypes.physiotherapy,
    translate("braids"): BusinessesTypes.braids,
    translate("makeUpArtist"): BusinessesTypes.makeUpArtist,
    translate("tattooArtist"): BusinessesTypes.tattooArtist,
    translate("hairRemoval"): BusinessesTypes.hairRemoval,
    translate("masseur"): BusinessesTypes.masseur,
    translate("Tutor"): BusinessesTypes.Tutor,
    translate("weddingDresses"): BusinessesTypes.weddingDresses,
    translate("danceTeacher"): BusinessesTypes.danceTeacher,
    translate("dietitian"): BusinessesTypes.dietitian,
    translate("carWash"): BusinessesTypes.carWash,
    translate("photographer"): BusinessesTypes.photographer,
    translate("swimmingTeacher"): BusinessesTypes.swimmingTeacher,
    translate("counselor"): BusinessesTypes.counselor,
    translate("mentor"): BusinessesTypes.mentor,
    translate("tennisCoach"): BusinessesTypes.tennisCoach,
    translate("privateChef"): BusinessesTypes.privateChef,
    translate("personalTrainer"): BusinessesTypes.personalTrainer,
    translate("lawyer"): BusinessesTypes.lawyer,
    translate("sales"): BusinessesTypes.sales,
    translate("realEstate"): BusinessesTypes.realEstate,
    translate("drivingTeacher"): BusinessesTypes.drivingTeacher,
    translate("investmentAdvice"): BusinessesTypes.investmentAdvice,
    translate("library"): BusinessesTypes.library,
    translate("other"): BusinessesTypes.other,
  };
}
