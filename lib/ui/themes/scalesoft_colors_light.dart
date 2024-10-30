import 'dart:ui';

import 'package:scalesoft_app/ui/themes/scale_colors.dart';

class ScaleColorsLight implements ScaleColors {
  @override
  Color paper = const Color(0xFFFFFFFF);

  @override
  Color paperAccent = const Color(0xFFFFFFFF);
  @override
  Color paperTransparent = const Color.fromARGB(184, 255, 255, 255);
  @override
  Color transparent = const Color(0x00000000);

  @override
  Color primary = const Color(0xFF0D6EFD);
  @override
  Color content100 = const Color(0xFF263238);
  @override
  Color content80 = const Color(0xFF607D8B);
  @override
  Color content60 = const Color(0xFFB0BEC5);
  @override
  Color content40 = const Color(0xFFE4EAEC);
  @override
  Color content20 = const Color(0xFFECF2F4);

  @override
  Color warning = const Color(0xFFFFC107);
  @override
  Color alert = const Color(0xFFF95357);
  @override
  Color positive = const Color(0xFF198754);

  @override
  Color dark = const Color(0xFF263238);
  @override
  Color light = const Color(0xFFFFFFFF);
  @override
  Color lightTransparent = const Color.fromARGB(82, 255, 255, 255);

  @override
  Color cardShadow = const Color.fromARGB(100, 0, 0, 0);

  @override
  Color actionStart = const Color(0xFF32B585);
  @override
  Color actionEnd = const Color(0xFF109383);

  @override
  Color orangeDark = const Color(0xFF94230A);

  @override
  Color orange20 = const Color(0xFFFFF3E4);
}
