import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_dark.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class AppearanceItem extends StatelessWidget {
  const AppearanceItem({
    super.key,
    required this.itemType,
    required this.isSelected,
    required this.onSelected,
  });

  final AppearanceItemType itemType;
  final bool isSelected;
  final VoidCallback onSelected;

  Color _getTitleColor(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? ScaleColorsLight.content100
        : ScaleColorsDark.content100;
  }

  Color _getSubTitleColor(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? ScaleColorsLight.content80
        : ScaleColorsDark.content80;
  }

  Color _getItemBackgroundColor(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? ScaleColorsLight.paperAccent
        : ScaleColorsDark.paperAccent;
  }

  Color _getRectColor(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? ScaleColorsLight.content20
        : ScaleColorsDark.content20;
  }

  String _getTitle(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? context.locale.configuration_screen_light
        : context.locale.configuration_screen_dark;
  }

  String _getSubTitle(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? context.locale.configuration_screen_good_in_day
        : context.locale.configuration_screen_good_in_night;
  }

  String _getIconPath(BuildContext context) {
    return itemType == AppearanceItemType.light
        ? 'assets/icons/icon_sun.svg'
        : 'assets/icons/icon_moon.svg';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadii.radius16,
      onTap: onSelected,
      child: Container(
        height: 96,
        padding: Paddings.all16,
        decoration: BoxDecoration(
          borderRadius: BorderRadii.radius16,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
          color: _getItemBackgroundColor(context),
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: Paddings.all14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadii.radius8,
                  color: _getRectColor(context),
                ),
                child: SvgPicture.asset(
                  _getIconPath(context),
                  color: _getSubTitleColor(context),
                ),
              ),
            ),
            Gaps.gap16,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(context),
                  style: ScaleTextStyles.text
                      .apply(color: _getTitleColor(context)),
                ),
                Text(
                  _getSubTitle(context),
                  style: ScaleTextStyles.label
                      .apply(color: _getSubTitleColor(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum AppearanceItemType { light, dark }
