/// Thes file is saving the const vars of the app display settings
/// example: save the different theme options

import 'package:flutter/material.dart';
import 'package:management_system_app/ui/themes/dark_theme.dart';

import '../ui/themes/light_theme.dart';

enum Themes { dark, light }

const Map<Themes, String> themeToStr = {
  Themes.dark: "dark",
  Themes.light: "light",
};

const Map<String, Themes> themeFromStr = {
  "dark": Themes.dark,
  "light": Themes.light,
};

Map<Themes, ThemeData> themes = {
  Themes.dark: DarkTheme,
  Themes.light: LightTheme,
};
