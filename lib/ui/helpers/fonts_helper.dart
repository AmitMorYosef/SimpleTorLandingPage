import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_tor_web/app_const/fonts.dart';

import '../../app_const/application_general.dart';
import '../../app_statics.dart/settings_data.dart';

class FontsHelper {
  // Return all the supported fonts names
  List<String> getOptionalFontsNames() {
    return GoogleFonts.asMap().keys.toList();
  }

  // Get: `langFilter`
  // Return all the fonts  that supported in the given langFilter
  List<String> getFilteredFontsNames({required Languages langFilter}) {
    if (!fontsByLang.containsKey(langFilter)) {
      logger
          .d("LangFilter ($langFilter) dosen't exist ->  return all languages");
      return GoogleFonts.asMap().keys.toList();
    }
    return GoogleFonts.asMap()
        .keys
        .toSet()
        .intersection(fontsByLang[langFilter]!)
        .toList();
  }

  /// Get: `currentStyle` and `fontName`
  /// Return it wrap with font style
  TextStyle? custumStyle({TextStyle? currentStyle, String? fontName}) {
    if (fontName == null) {
      return currentStyle;
    }
    if (!GoogleFonts.asMap().containsKey(fontName)) {
      return currentStyle;
    }
    return GoogleFonts.asMap()[fontName]!(textStyle: currentStyle);
  }

  /// Get: `currentStyle` and Return it wrap with font style of the business
  TextStyle? businessStyle({TextStyle? currentStyle}) {
    if (!GoogleFonts.asMap().containsKey(SettingsData.settings.fontName)) {
      return currentStyle;
    }
    return GoogleFonts.asMap()[SettingsData.settings.fontName]!(
        textStyle: currentStyle);
  }
}
