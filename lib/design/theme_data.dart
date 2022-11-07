import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/design/color_constants.dart';

final uniqartTheme = _buildUniqartTheme();

ThemeData _buildUniqartTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _uniqartColorScheme,

    primaryColor: uniqartPrimary,

    scaffoldBackgroundColor: uniqartBackgroundWhite,
    cardColor: uniqartOnSurface,
    errorColor: uniqartErrorRed,
    // buttonTheme: const ButtonThemeData(
    //   colorScheme: _uniqartColorScheme,
    //   textTheme: ButtonTextTheme.accent,
    // ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // This is a custom color variable
        textStyle: GoogleFonts.lato(color: Colors.blue),
      ),
    ),
    primaryIconTheme: _customUniqartIconTheme(base.primaryIconTheme),
    textTheme: _buildUniqartextTheme(base.textTheme),
    primaryTextTheme: _buildUniqartextTheme(base.primaryTextTheme),
    // iconTheme: _customUniqartIconTheme(base.iconTheme),
    appBarTheme: _buildUniqartAppBarTheme(base.appBarTheme),

    bottomNavigationBarTheme:
        _buildUniqartBottomNavigationBarTheme(base.bottomNavigationBarTheme),
  );
}

IconThemeData _customUniqartIconTheme(IconThemeData base) {
  return base.copyWith(
    color: uniqartBackgroundWhite,
    size: 24,
  );
}

TextTheme _buildUniqartextTheme(TextTheme base) {
  return base
      .copyWith(
        headline1: GoogleFonts.lato(
          fontSize: 100,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.5,
        ),
        headline2: GoogleFonts.lato(
          fontSize: 62,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        headline3: GoogleFonts.lato(fontSize: 50, fontWeight: FontWeight.w400),
        headline4: GoogleFonts.lato(
          fontSize: 35,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        headline5: GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.w400),
        headline6: GoogleFonts.lato(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        subtitle1: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        subtitle2: GoogleFonts.lato(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyText1: GoogleFonts.lato(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyText2: GoogleFonts.lato(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        button: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        caption: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        overline: GoogleFonts.lato(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      )
      .apply(
          fontFamily: "Lato",
          displayColor: uniqartTextField,
          bodyColor: uniqartTextField,
          decorationColor: uniqartTextField);
}

AppBarTheme _buildUniqartAppBarTheme(AppBarTheme base) {
  return base.copyWith(
      backgroundColor: uniqartPrimary,
      iconTheme: const IconThemeData(color: uniqartTextField),
      shadowColor: uniqartOnSurface,
      titleTextStyle: GoogleFonts.lato(
        color: uniqartOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ));
}

BottomNavigationBarThemeData _buildUniqartBottomNavigationBarTheme(
    BottomNavigationBarThemeData base) {
  return base.copyWith(
      backgroundColor: uniqartSurfaceWhite,
      selectedItemColor: uniqartPrimary,
      unselectedItemColor: uniqartDisabled);
}

const ColorScheme _uniqartColorScheme = ColorScheme(
  primary: uniqartPrimary,
  secondary: uniqartSecondary,
  surface: uniqartOnSurface,
  background: uniqartBackgroundWhite,
  error: uniqartErrorRed,
  onPrimary: uniqartSurfaceWhite,
  onSecondary: uniqartSurfaceWhite,
  onSurface: uniqartSurfaceWhite,
  onBackground: uniqartOnSurface,
  onError: uniqartErrorRed,
  brightness: Brightness.light,
);
