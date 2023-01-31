import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/auth_data.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';

class Constants {
  /* API */
  //static const String baseUrl = 'https://in2-win.devscale.cz/api-mobile/v1';
  static const String privateDioName = 'privateDio';

  /* OAuth2 */
  static const String clientSecret = 'cqWFWo9zYQHFh38kS8VC';
  static const String clientId = 'MobileApp';
  static const List<String> scopes = [
    'openid',
    'profile',
    'offline_access',
    'mobile_api.Default',
  ];
  static const String redirectUrl = 'cz.scalesoft.tlm://auth-callback';

  static const double appBarHeight = 56;
  static const double twoLinedBarHeight = 76;
  static const double bottomTabBarHeight = 56;
  static const double navigationTabBarHeight = 32;
  static const double buttonHeight = 48;
  static const double searchBarHeight = 48;

  static const double actionActiveWidgetHeight =
      16 + 20 + 16 + buttonHeight + 16;
  static const double actionPassiveWidgetHeight = 16 + 20 + 16;

  static const List<Hospital> hospitals = [
    Hospital(
      id: 0,
      title: 'in2-win',
      iconPath: 'assets/icons/icon_hospital_ikem.svg',
      authData: AuthData(
        baseUrl: 'https://in2-win.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-win-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-win-auth.devscale.cz/connect/token',
      ),
    ),
    Hospital(
      id: 1,
      title: 'in2-test',
      iconPath: 'assets/icons/icon_hospital_nahomolce.svg',
      authData: AuthData(
        baseUrl: 'https://in2-test.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-test-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-test-auth.devscale.cz/connect/token',
      ),
    ),
    Hospital(
      id: 2,
      title: 'in2',
      iconPath: 'assets/icons/icon_hospital_user.svg',
      authData: AuthData(
        baseUrl: 'https://in2.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-auth.devscale.cz/connect/token',
      ),
    ),
  ];
}

class Paddings {
  static const EdgeInsetsGeometry left5 =
      EdgeInsets.only(left: Dimensions.padding5);
  static const EdgeInsetsGeometry left8 =
      EdgeInsets.only(left: Dimensions.padding8);
  static const EdgeInsetsGeometry left10 =
      EdgeInsets.only(left: Dimensions.padding10);
  static const EdgeInsetsGeometry left16 =
      EdgeInsets.only(left: Dimensions.padding16);
  static const EdgeInsetsGeometry left20 =
      EdgeInsets.only(left: Dimensions.padding20);
  static const EdgeInsetsGeometry left32 =
      EdgeInsets.only(left: Dimensions.padding32);
  static const EdgeInsetsGeometry left48 =
      EdgeInsets.only(left: Dimensions.padding48);

  static const EdgeInsetsGeometry right5 =
      EdgeInsets.only(right: Dimensions.padding5);
  static const EdgeInsetsGeometry right8 =
      EdgeInsets.only(right: Dimensions.padding8);
  static const EdgeInsetsGeometry right10 =
      EdgeInsets.only(right: Dimensions.padding10);
  static const EdgeInsetsGeometry right20 =
      EdgeInsets.only(right: Dimensions.padding20);
  static const EdgeInsetsGeometry right32 =
      EdgeInsets.only(right: Dimensions.padding32);
  static const EdgeInsetsGeometry right48 =
      EdgeInsets.only(right: Dimensions.padding48);

  static const EdgeInsetsGeometry top5 =
      EdgeInsets.only(top: Dimensions.padding5);
  static const EdgeInsetsGeometry top8 =
      EdgeInsets.only(top: Dimensions.padding8);
  static const EdgeInsetsGeometry top10 =
      EdgeInsets.only(top: Dimensions.padding10);
  static const EdgeInsetsGeometry top16 =
      EdgeInsets.only(top: Dimensions.padding16);
  static const EdgeInsetsGeometry top20 =
      EdgeInsets.only(top: Dimensions.padding20);
  static const EdgeInsetsGeometry top30 =
      EdgeInsets.only(top: Dimensions.padding30);
  static const EdgeInsetsGeometry top32 =
      EdgeInsets.only(top: Dimensions.padding32);
  static const EdgeInsetsGeometry top48 =
      EdgeInsets.only(top: Dimensions.padding48);

  static const EdgeInsetsGeometry bottom5 =
      EdgeInsets.only(bottom: Dimensions.padding5);
  static const EdgeInsetsGeometry bottom8 =
      EdgeInsets.only(bottom: Dimensions.padding8);
  static const EdgeInsetsGeometry bottom10 =
      EdgeInsets.only(bottom: Dimensions.padding10);
  static const EdgeInsetsGeometry bottom20 =
      EdgeInsets.only(bottom: Dimensions.padding20);
  static const EdgeInsetsGeometry bottom32 =
      EdgeInsets.only(bottom: Dimensions.padding32);
  static const EdgeInsetsGeometry bottom48 =
      EdgeInsets.only(bottom: Dimensions.padding48);

  static const EdgeInsetsGeometry horizontal4 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding4);
  static const EdgeInsetsGeometry horizontal5 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding5);
  static const EdgeInsetsGeometry horizontal8 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding8);
  static const EdgeInsetsGeometry horizontal10 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding10);
  static const EdgeInsetsGeometry horizontal16 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding16);
  static const EdgeInsetsGeometry horizontal20 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding20);
  static const EdgeInsetsGeometry horizontal32 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding32);
  static const EdgeInsetsGeometry horizontal48 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding48);
  static const EdgeInsetsGeometry horizontal64 =
      EdgeInsets.symmetric(horizontal: Dimensions.padding64);

  static const EdgeInsetsGeometry vertical4 =
      EdgeInsets.symmetric(vertical: Dimensions.padding4);
  static const EdgeInsetsGeometry vertical5 =
      EdgeInsets.symmetric(vertical: Dimensions.padding5);
  static const EdgeInsetsGeometry vertical8 =
      EdgeInsets.symmetric(vertical: Dimensions.padding8);
  static const EdgeInsetsGeometry vertical10 =
      EdgeInsets.symmetric(vertical: Dimensions.padding10);
  static const EdgeInsetsGeometry vertical12 =
      EdgeInsets.symmetric(vertical: Dimensions.padding12);
  static const EdgeInsetsGeometry vertical16 =
      EdgeInsets.symmetric(vertical: Dimensions.padding16);
  static const EdgeInsetsGeometry vertical20 =
      EdgeInsets.symmetric(vertical: Dimensions.padding20);
  static const EdgeInsetsGeometry vertical32 =
      EdgeInsets.symmetric(vertical: Dimensions.padding32);
  static const EdgeInsetsGeometry vertical48 =
      EdgeInsets.symmetric(vertical: Dimensions.padding48);

  static const EdgeInsetsGeometry all4 = EdgeInsets.all(Dimensions.padding4);
  static const EdgeInsetsGeometry all5 = EdgeInsets.all(Dimensions.padding5);
  static const EdgeInsetsGeometry all8 = EdgeInsets.all(Dimensions.padding8);
  static const EdgeInsetsGeometry all10 = EdgeInsets.all(Dimensions.padding10);
  static const EdgeInsetsGeometry all12 = EdgeInsets.all(Dimensions.padding12);
  static const EdgeInsetsGeometry all14 = EdgeInsets.all(Dimensions.padding14);
  static const EdgeInsetsGeometry all16 = EdgeInsets.all(Dimensions.padding16);
  static const EdgeInsetsGeometry all20 = EdgeInsets.all(Dimensions.padding20);
  static const EdgeInsetsGeometry all32 = EdgeInsets.all(Dimensions.padding32);
  static const EdgeInsetsGeometry all30 = EdgeInsets.all(Dimensions.padding30);
  static const EdgeInsetsGeometry all48 = EdgeInsets.all(Dimensions.padding48);
}

class BorderRadii {
  static BorderRadius radius2 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius2));
  static BorderRadius radius4 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius4));
  static BorderRadius radius6 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius6));
  static BorderRadius radius8 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius8));
  static BorderRadius radius10 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius10));
  static BorderRadius radius12 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius12));
  static BorderRadius radius15 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius15));
  static BorderRadius radius16 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius16));
  static BorderRadius radius20 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius20));
  static BorderRadius radius30 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius30));
  static BorderRadius radius50 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius50));
  static BorderRadius radius64 =
      const BorderRadius.all(Radius.circular(RadiusSize.radius64));
}

class Gaps {
  static Gap gap2 = const Gap(Dimensions.padding2);
  static Gap gap4 = const Gap(Dimensions.padding4);
  static Gap gap5 = const Gap(Dimensions.padding5);
  static Gap gap6 = const Gap(Dimensions.padding6);
  static Gap gap7 = const Gap(Dimensions.padding7);
  static Gap gap8 = const Gap(Dimensions.padding8);
  static Gap gap10 = const Gap(Dimensions.padding10);
  static Gap gap12 = const Gap(Dimensions.padding12);
  static Gap gap14 = const Gap(Dimensions.padding14);
  static Gap gap16 = const Gap(Dimensions.padding16);
  static Gap gap17 = const Gap(Dimensions.padding17);
  static Gap gap20 = const Gap(Dimensions.padding20);
  static Gap gap24 = const Gap(Dimensions.padding24);
  static Gap gap26 = const Gap(Dimensions.padding26);
  static Gap gap30 = const Gap(Dimensions.padding30);
  static Gap gap32 = const Gap(Dimensions.padding32);
  static Gap gap34 = const Gap(Dimensions.padding34);
  static Gap gap35 = const Gap(Dimensions.padding35);
  static Gap gap36 = const Gap(Dimensions.padding36);
  static Gap gap42 = const Gap(Dimensions.padding42);
  static Gap gap48 = const Gap(Dimensions.padding48);
  static Gap gap60 = const Gap(Dimensions.padding60);
}

class Dimensions {
  static const double padding2 = 2;
  static const double padding4 = 4;
  static const double padding5 = 5;
  static const double padding6 = 6;
  static const double padding7 = 7;
  static const double padding8 = 8;
  static const double padding10 = 10;
  static const double padding12 = 12;
  static const double padding14 = 14;
  static const double padding16 = 16;
  static const double padding17 = 17;
  static const double padding20 = 20;
  static const double padding24 = 24;
  static const double padding25 = 25;
  static const double padding26 = 26;
  static const double padding30 = 30;
  static const double padding32 = 32;
  static const double padding34 = 34;
  static const double padding35 = 35;
  static const double padding36 = 36;
  static const double padding42 = 42;
  static const double padding48 = 48;
  static const double padding60 = 60;
  static const double padding64 = 64;
}

class RadiusSize {
  static const double radius2 = 2;
  static const double radius4 = 4;
  static const double radius6 = 6;
  static const double radius8 = 8;
  static const double radius10 = 10;
  static const double radius12 = 12;
  static const double radius15 = 15;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  static const double radius30 = 30;
  static const double radius50 = 50;
  static const double radius64 = 64;
  static const double radius120 = 120;
  static const double radius140 = 140;
  static const double radius186 = 186;
}
