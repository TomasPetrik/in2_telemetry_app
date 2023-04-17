import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppearanceHelper {
  static void setSystemUIOverlayStyle(ThemeMode mode) {
    SystemChrome.setSystemUIOverlayStyle(
      mode == ThemeMode.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }
}
