import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Color temp = Color.fromARGB(255, 198, 104, 137);

// Map<int, Color> color = {
//   50: temp,
//   100: temp,
//   200: temp,
//   300: temp,
//   400: temp,
//   500: temp,
//   600: temp,
//   700: temp,
//   800: temp,
//   900: temp,
// };

// final primaryColor = MaterialColor(0xFF000000, color);
// final primarySwatch =
//     Color(0xFF4C0027); // cuersers -> dots (calendar selctions day and date)
// final secondaryColor = Colors.white; // icons and text
// final backgroundColor = Color(0xFF980F5A); // background
// final surface = Color(0xFF750550); // custom container

Color temp = Color(0xffFF87B2);

Map<int, Color> color = {
  50: temp,
  100: temp,
  200: temp,
  300: temp,
  400: temp,
  500: temp,
  600: temp,
  700: temp,
  800: temp,
  900: temp,
};

final primaryColor = MaterialColor(0xFFFF87B2, color);
final secondaryColor = Color(0xff40393A);
final colorOnSurface = Colors.white;
final backgroundColor =
    Color(0xffF6F6F6); // Color.fromARGB(255, 241, 210, 199);
final surface = Color(0xffFFFFFF);
final primarySwatch = Color(0xFFFF87B2);
final cards = Color(0xffFFF4F6).withOpacity(0.8);

ThemeData LightTheme = ThemeData(
    colorScheme: ColorScheme(
        error: Color.fromARGB(255, 157, 40, 40),
        onError: Color.fromARGB(255, 136, 34, 34),
        surface: surface,
        onBackground: secondaryColor,
        background: backgroundColor,
        secondary: primarySwatch,
        onSecondary: colorOnSurface,
        brightness: Brightness.light,
        onSurface: secondaryColor,
        primary: primaryColor,
        onPrimary: secondaryColor,
        tertiary: cards),
    fontFamily: "Inter",
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.varelaRound(
          textStyle: TextStyle(
        color: colorOnSurface,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      )),
      bodyMedium: GoogleFonts.varelaRound(
          textStyle: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
      titleLarge: TextStyle(
          color: secondaryColor.withOpacity(0.5),
          fontSize: 18,
          fontWeight: FontWeight.w800), //headline for all dialogs titles
      headlineSmall: TextStyle(
          color: secondaryColor, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: secondaryColor, fontSize: 25, fontWeight: FontWeight.w400),
      displaySmall:
          TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
    ),
    brightness: Brightness.light,
    primarySwatch: primaryColor,
    primaryColor: primaryColor,
    dialogTheme: DialogTheme(
        contentTextStyle: GoogleFonts.ptSans(
            textStyle: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14))),
    dialogBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
            color: secondaryColor.withOpacity(0.5),
            fontSize: 18,
            fontWeight: FontWeight.w800),
        iconTheme: IconThemeData(color: secondaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark),
    iconTheme: IconThemeData(color: secondaryColor));
