import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class LightMode {
  static Color get backgroundColor => ScaleColorsLight.paper;

  static Color get primary => ScaleColorsLight.primary;

  static Color get fontColor => ScaleColorsLight.content100;

  static Color get colorContent80 => ScaleColorsLight.content80;

  static Color get colorContent60 => ScaleColorsLight.content60;

  static Color get colorContent40 => ScaleColorsLight.content60;

  static Color get colorContent20 => ScaleColorsLight.content20;

  static Color get paperAccent => ScaleColorsLight.paperAccent;

  static Color get alertColor => ScaleColorsLight.alert;

  static Color get actionStartColor => ScaleColorsLight.actionStart;

  static Color get actionEndColor => ScaleColorsLight.actionEnd;

  static Color get light => ScaleColorsLight.light;

  static Color get lightTransparent => ScaleColorsLight.lightTransparent;

  static Color get dark => ScaleColorsLight.dark;

  static Color get positive => ScaleColorsLight.positive;

  static Color get warning => ScaleColorsLight.warning;

  static Color get cardShadow => ScaleColorsLight.cardShadow;

  static ColorScheme get colorScheme => ColorScheme(
        background: backgroundColor,
        brightness: Brightness.light,
        error: alertColor,
        onBackground: paperAccent,
        onError: warning,
        onPrimary: fontColor,
        onSecondary: colorContent80,
        surface: dark,
        onSurface: light,
        surfaceTint: lightTransparent,
        onSurfaceVariant: colorContent40,
        primary: primary,
        secondary: colorContent20,
        primaryContainer: actionStartColor,
        onPrimaryContainer: actionEndColor,
        tertiary: colorContent60,
        onTertiary: positive,
      );

  static ThemeData get theme => ThemeData(
        primaryColor: primary,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        canvasColor: backgroundColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: paperAccent,
        hintColor: colorContent80,
        colorScheme: colorScheme,
        dividerTheme: DividerThemeData(color: colorContent20),
        listTileTheme: ListTileThemeData(
          titleTextStyle: ScaleTextStyles.textAccent.apply(color: fontColor),
          subtitleTextStyle: ScaleTextStyles.label.apply(color: colorContent80),
          iconColor: primary,
        ),
        cardTheme: CardTheme(
          elevation: Dimensions.cardElevation,
          shadowColor: cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadii.radius16,
          ),
          margin: EdgeInsets.zero,
        ),
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
          labelStyle: ScaleTextStyles.text.apply(color: fontColor),
          iconColor: primary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding16,
            vertical: Dimensions.padding14,
          ),
          hintStyle: ScaleTextStyles.text.apply(color: colorContent60),
          border: OutlineInputBorder(
            borderRadius: BorderRadii.radius8,
            borderSide: BorderSide(
              color: colorContent60,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadii.radius8,
            borderSide: BorderSide(
              color: colorContent60,
              width: 1,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadii.radius8,
            borderSide: BorderSide(
              color: colorContent60,
              width: 1,
            ),
          ),
          errorStyle: ScaleTextStyles.label.apply(
            color: alertColor,
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
        dialogTheme: DialogTheme(
          backgroundColor: light,
          titleTextStyle: ScaleTextStyles.title.apply(color: fontColor),
          contentTextStyle: ScaleTextStyles.label.apply(color: colorContent80),
        ),
      );
}
