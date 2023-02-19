import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplicationLocalizations {
  final Locale appLocale;

  ApplicationLocalizations(this.appLocale);
  static const LocalizationsDelegate<ApplicationLocalizations> delegate =
      _ApplicationLocalizationsDelegate();

  static ApplicationLocalizations? of(BuildContext context) {
    return Localizations.of<ApplicationLocalizations>(
        context, ApplicationLocalizations);
  }

  static late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load JSON file from the "language" folder
    String jsonString = await rootBundle
        .loadString('resources/language/${appLocale.languageCode}.json');
    Map<String, dynamic> jsonLanguageMap = json.decode(jsonString);
    _localizedStrings = jsonLanguageMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  bool isRTL() {
    List<String> rtlLangs = [
      "ar",
      "arc",
      "dv",
      "fa",
      "ha",
      "he",
      "khw",
      "ks",
      "ku",
      "ps",
      "ur",
      "yi"
    ];
    return rtlLangs.contains(appLocale.languageCode);
  }

  // called from every widget which needs a localized text
  static String translate(String jsonkey) {
    return "${_localizedStrings[jsonkey]}";
  }
}

class _ApplicationLocalizationsDelegate
    extends LocalizationsDelegate<ApplicationLocalizations> {
  const _ApplicationLocalizationsDelegate();

  @override
  Future<ApplicationLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    ApplicationLocalizations localizations = ApplicationLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_ApplicationLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) {
    return ['en', 'he'].contains(locale.languageCode);
  }
}
