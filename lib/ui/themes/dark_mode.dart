import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_dark.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class DarkMode {
  static final ScaleColorsDark _colors = ScaleColorsDark();

  static Color get backgroundColor => _colors.paper;

  static Color get primary => _colors.primary;

  static Color get fontColor => _colors.content100;

  static Color get colorContent80 => _colors.content80;

  static Color get colorContent60 => _colors.content60;

  static Color get colorContent40 => _colors.content40;

  static Color get colorContent20 => _colors.content20;

  static Color get paperAccent => _colors.paperAccent;

  static Color get alertColor => _colors.alert;

  static Color get actionStartColor => _colors.actionStart;

  static Color get actionEndColor => _colors.actionEnd;

  static Color get light => _colors.light;

  static Color get lightTransparent => _colors.lightTransparent;

  static Color get dark => _colors.dark;

  static Color get positive => _colors.positive;

  static Color get warning => _colors.warning;

  static Color get cardShadow => _colors.cardShadow;

  static ButtonStyle elevatedButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateColor.resolveWith(
      (states) => states.isNotEmpty && states.first == MaterialState.pressed
          ? colorContent20.withOpacity(0.5)
          : colorContent20,
    ),
    textStyle: MaterialStateProperty.all<TextStyle>(
      ScaleTextStyles.textAccent.apply(
        color: fontColor,
      ),
    ),
    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadii.radius8,
      ),
    ),
  );

  static ColorScheme get colorScheme => ColorScheme(
        background: backgroundColor,
        brightness: Brightness.dark,
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
          titleTextStyle: ScaleTextStyles.text.apply(color: fontColor),
          subtitleTextStyle: ScaleTextStyles.label.apply(color: colorContent60),
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
          backgroundColor: _colors.paperTransparent,
          titleTextStyle: TextStyle(
            backgroundColor: backgroundColor,
            color: fontColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: _colors.paper,
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
          errorStyle: ScaleTextStyles.label.copyWith(
            color: alertColor,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: elevatedButtonStyle,
        ),
      );
}
