import 'package:flutter/cupertino.dart';
import 'package:scalesoft_app/utils/scale_colors.dart';

class ScaleTextStyles {
  static const TextStyle genericTextStyle = TextStyle(color: ScaleColors.mainText1);

  static TextStyle headingStyle = genericTextStyle.copyWith(height: 1.3, fontWeight: FontWeight.w700);
  static TextStyle subtitleStyle = genericTextStyle.copyWith(height: 1.3);
  static TextStyle bodyStyle = genericTextStyle.copyWith(fontWeight: FontWeight.w400);
  static TextStyle labelStyle = genericTextStyle.copyWith(fontWeight: FontWeight.w400);
  static TextStyle buttonStyle = genericTextStyle.copyWith(fontWeight: FontWeight.w600);
  static TextStyle allCapsStyle = genericTextStyle.copyWith(fontWeight: FontWeight.w400);
  static TextStyle allCapsBoldStyle = genericTextStyle.copyWith();

  static TextStyle heading1 = headingStyle.copyWith(fontSize: 34);
  static TextStyle heading2 = headingStyle.copyWith(fontSize: 28);
  static TextStyle heading3 = headingStyle.copyWith(fontSize: 24);
  static TextStyle heading4 = headingStyle.copyWith(fontSize: 20);

  static TextStyle subtitleXl = subtitleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w500);
  static TextStyle subtitleL = subtitleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle subtitleM = subtitleStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w500);
  static TextStyle subtitleS = subtitleStyle.copyWith(fontSize: 13, height: 1.69, fontWeight: FontWeight.w600);

  static TextStyle bodyXl = bodyStyle.copyWith(fontSize: 20, height: 1.6);
  static TextStyle bodyL = bodyStyle.copyWith(fontSize: 17, height: 1.6);
  static TextStyle bodyM = bodyStyle.copyWith(fontSize: 15, height: 1.45);
  static TextStyle bodyS = bodyStyle.copyWith(fontSize: 13, height: 1.45);
  static TextStyle bodyXs = bodyStyle.copyWith(fontSize: 12, height: 1.6);
  static TextStyle bodyXxs = bodyStyle.copyWith(fontSize: 10, height: 1.6);

  static TextStyle labelM = labelStyle.copyWith(fontSize: 15, height: 1.2);
  static TextStyle labelS = labelStyle.copyWith(fontSize: 13, height: 1.2);
  static TextStyle labelXs = labelStyle.copyWith(fontSize: 12, height: 1.0);
  static TextStyle labelXxs = labelStyle.copyWith(fontSize: 10, height: 1.0);

  static TextStyle buttonM = buttonStyle.copyWith(fontSize: 15, height: 1.0);
  static TextStyle buttonS = buttonStyle.copyWith(fontSize: 13, height: 1.0);
  static TextStyle buttonXs = buttonStyle.copyWith(fontSize: 12, height: 1.0);

  static TextStyle allCapsM = allCapsStyle.copyWith(fontSize: 16, height: 1.1);
  static TextStyle allCapsS = allCapsStyle.copyWith(fontSize: 14, height: 1.1);
  static TextStyle allCapsXs = allCapsStyle.copyWith(fontSize: 12, height: 1.1);
  static TextStyle allCapsXxs = allCapsStyle.copyWith(fontSize: 10, height: 1.1);

  static TextStyle allCapsBoldM = allCapsM.copyWith(fontWeight: FontWeight.w700);
  static TextStyle allCapsBoldS = allCapsS.copyWith(fontWeight: FontWeight.w600);
  static TextStyle allCapsBoldXs = allCapsXs.copyWith(fontWeight: FontWeight.w400);
  static TextStyle allCapsBoldXxs = allCapsXxs.copyWith(fontWeight: FontWeight.w700);

  static TextStyle navTitle = const TextStyle(color: ScaleColors.mainText1, fontSize: 16, fontWeight: FontWeight.bold);
}
