import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_dark.dart';

class DarkMode {
  static Color get backgroundColor => ScaleColorsDark.paper;

  static Color get buttonColor => ScaleColorsDark.primary;

  static Color get fontColor => ScaleColorsDark.content100;

  static Color get colorContent80 => ScaleColorsDark.content80;

  static Color get colorContent20 => ScaleColorsDark.content20;

  static Color get cardColor => ScaleColorsDark.paperAccent;

  static TextTheme get textTheme => TextTheme(
        headlineLarge: TextStyle(fontSize: 36, height: 1.33, fontWeight: FontWeight.w700, color: fontColor), //big
        headlineMedium: TextStyle(fontSize: 28, height: 1.14, fontWeight: FontWeight.w700, color: fontColor), //headline
        titleLarge: TextStyle(fontSize: 22, height: 1.27, fontWeight: FontWeight.w600, color: fontColor), //title
        bodyMedium: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w500, color: fontColor), //text
        titleMedium: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w700, color: fontColor), //textAccent
        labelSmall: TextStyle(fontSize: 13, height: 1.23, fontWeight: FontWeight.w700, color: fontColor), //label
      );

  static ThemeData get theme => ThemeData(
        primaryColor: ScaleColorsDark.primary,
        canvasColor: backgroundColor,
        backgroundColor: backgroundColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        highlightColor: buttonColor,
        textTheme: textTheme,
        hintColor: colorContent80,
        selectedRowColor: colorContent20,
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: ScaleColorsDark.primary),
          backgroundColor: ScaleColorsDark.paperTransparent,
          titleTextStyle: TextStyle(
            backgroundColor: backgroundColor,
            color: fontColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: ScaleColorsDark.paper,
          labelStyle: TextStyle(color: fontColor),
          iconColor: ScaleColorsDark.primary,
          hintStyle: const TextStyle(fontSize: 16.0, color: ScaleColorsDark.content40),
          border: InputBorder.none,
          errorStyle: const TextStyle(
            color: ScaleColorsDark.alert,
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
              (states) => states.isNotEmpty && states.first == MaterialState.pressed ? buttonColor.withOpacity(0.5) : buttonColor,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadii.radius8,
              ),
            ),
          ),
        ),
      );
}
