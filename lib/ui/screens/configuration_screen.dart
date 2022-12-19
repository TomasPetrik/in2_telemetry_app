import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/appearance_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/notifications_settings_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: Paddings.horizontal16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(MediaQuery.of(context).viewPadding.top + Constants.appBarHeight),
                  Gaps.gap16,
                  Center(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      height: 64,
                      width: 64,
                    ),
                  ),
                  Gaps.gap42,
                  Text(
                    context.locale.configuration_screen_logged_accounts,
                    style: ScaleTextStyles.textAccent.apply(
                      color: ScaleColorsLight.content80,
                    ),
                  ),
                  Gaps.gap24,
                  SettingsItem(
                    label: context.locale.configuration_screen_add_account,
                    icon: Icons.add,
                    onTap: () {},
                  ),
                  Gaps.gap42,
                  Text(
                    context.locale.configuration_screen_settings,
                    style: ScaleTextStyles.textAccent.apply(
                      color: ScaleColorsLight.content80,
                    ),
                  ),
                  Gaps.gap24,
                  SettingsItem(
                    label: context.locale.configuration_screen_notification_label,
                    subLabel: context.locale.configuration_screen_notification_sublabel,
                    icon: Icons.announcement,
                    onTap: () {
                      Navigator.of(context).pushNamed(NotificationsSettingsScreen.routeName);
                    },
                  ),
                  Gaps.gap24,
                  SettingsItem(
                    label: context.locale.configuration_screen_appearance_label,
                    subLabel: context.locale.configuration_screen_appearance_sublabel,
                    icon: Icons.imagesearch_roller,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppearanceSettingsScreen.routeName);
                    },
                  ),
                  const Gap(300),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BluredUserAppBar(
              title: context.locale.common_telemedicine,
            ),
          ),
        ],
      ),
    );
  }
}
