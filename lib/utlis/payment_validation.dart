import 'package:simple_tor_web/utlis/string_utlis.dart';

String stringValidation(String field, {int max = 50}) {
  if (field.length < 2) return translate("ToShortField");
  if (field.length > max) return translate("ToLongField");
  return '';
}

String numbersValidation(String field) {
  if (!RegExp(r'^[0-9]+$').hasMatch(field)) return translate("onlyNumbers");
  return stringValidation(field, max: 20);
}
