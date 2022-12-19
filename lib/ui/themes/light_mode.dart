import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';

class LightMode {
  static Color get backgroundColor => ScaleColorsLight.paper;

  static Color get primary => ScaleColorsLight.primary;

  static Color get fontColor => ScaleColorsLight.content100;

  static Color get colorContent80 => ScaleColorsLight.content80;

  static Color get paperAccent => ScaleColorsLight.paperAccent;

  static Color get alertColor => ScaleColorsLight.alert;

  static Color get actionStartColor => ScaleColorsLight.actionStart;

  static Color get actionEndColor => ScaleColorsLight.actionEnd;

  static Color get light => ScaleColorsLight.light;

  static Color get dark => ScaleColorsLight.dark;

  static TextTheme get textTheme => TextTheme(
        headlineLarge: TextStyle(fontSize: 36, height: 1.33, fontWeight: FontWeight.w700, color: fontColor), //big
        headlineMedium: TextStyle(fontSize: 28, height: 1.14, fontWeight: FontWeight.w700, color: fontColor), //headline
        titleLarge: TextStyle(fontSize: 22, height: 1.27, fontWeight: FontWeight.w600, color: fontColor), //title
        bodyMedium: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w500, color: fontColor), //text
        titleMedium: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w700, color: fontColor), //textAccent
        labelSmall: TextStyle(fontSize: 13, height: 1.23, fontWeight: FontWeight.w700, color: fontColor), //label
      );

  static ColorScheme get colorScheme => ColorScheme(
        background: backgroundColor,
        brightness: Brightness.dark,
        error: alertColor,
        onBackground: backgroundColor,
        onError: alertColor,
        onPrimary: fontColor,
        onSecondary: colorContent80,
        onSurface: backgroundColor,
        primary: primary,
        secondary: paperAccent,
        surface: backgroundColor,
        primaryContainer: actionStartColor,
        onPrimaryContainer: actionEndColor,
        
      );
  static ThemeData get theme => ThemeData(
        primaryColor: ScaleColorsLight.primary,
        canvasColor: backgroundColor,
        backgroundColor: backgroundColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: paperAccent,
        highlightColor: primary,
        hintColor: colorContent80,
        textTheme: textTheme,
        colorScheme: colorScheme,
        primaryColorLight: light,
        primaryColorDark: dark,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: primary),
          backgroundColor: ScaleColorsLight.paperTransparent,
          titleTextStyle: TextStyle(
            backgroundColor: backgroundColor,
            color: fontColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: ScaleColorsLight.paper,
          labelStyle: TextStyle(color: fontColor),
          iconColor: ScaleColorsLight.primary,
          hintStyle: const TextStyle(fontSize: 16.0, color: ScaleColorsLight.content40),
          border: InputBorder.none,
          errorStyle: const TextStyle(
            color: ScaleColorsLight.alert,
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
              (states) =>
                  states.isNotEmpty && states.first == MaterialState.pressed ? primary.withOpacity(0.5) : primary,
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
