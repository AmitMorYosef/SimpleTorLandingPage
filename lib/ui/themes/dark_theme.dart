import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Color temp = Color(0xFF4C4C4F);

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

final primaryColor = MaterialColor(0xFF4C4C4F, color);
final primarySwatch = Colors.orange;
final secondaryColor = Colors.white;
final backgroundColor = Color(0xFF1F1F29);
final surface = Color(0xff252530);
final cards = Color(0xFF4E4E61).withOpacity(.2);

ThemeData DarkTheme = ThemeData(
    colorScheme: ColorScheme(
        error: Color.fromARGB(255, 157, 40, 40),
        onError: Color.fromARGB(255, 136, 34, 34),
        surface: surface,
        onBackground: secondaryColor,
        background: backgroundColor,
        secondary: primarySwatch,
        onSecondary: secondaryColor,
        brightness: Brightness.dark,
        onSurface: secondaryColor,
        primary: primaryColor,
        onPrimary: secondaryColor,
        tertiary: cards),
    fontFamily: "Inter",
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.ptSans(
          textStyle: TextStyle(
        color: secondaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      )),
      bodyMedium: GoogleFonts.ptSans(
          textStyle: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14)),
      titleLarge: TextStyle(
          color: secondaryColor.withOpacity(0.7),
          fontSize: 18,
          fontWeight: FontWeight.w800), //headline for all dialogs titles
      headlineSmall: TextStyle(
          color: secondaryColor, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: secondaryColor, fontSize: 25, fontWeight: FontWeight.w400),
      displaySmall:
          TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
    ),
    canvasColor: surface,
    brightness: Brightness.dark,
    dialogTheme: DialogTheme(
        contentTextStyle: GoogleFonts.ptSans(
            textStyle: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14))),
    primarySwatch: primarySwatch,
    primaryColor: primaryColor,
    dialogBackgroundColor: backgroundColor,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: primarySwatch,
        selectionColor: primarySwatch.withOpacity(0.5),
        selectionHandleColor: primarySwatch.withOpacity(0.5)),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(primarySwatch))),
    appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
            color: secondaryColor.withOpacity(0.5),
            fontSize: 18,
            fontWeight: FontWeight.w800),
        iconTheme: IconThemeData(color: secondaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.light),
    iconTheme: IconThemeData(color: secondaryColor.withOpacity(0.9)));
