import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/appearance_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/hospital_users_screen.dart';
import 'package:scalesoft_app/ui/screens/notifications_settings_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountDbProvider accountDbProvider = getIt<AccountDbProvider>();

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.locale.configuration_screen_logged_accounts,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Gaps.gap24,
                  ...accountDbProvider
                      .getHospitalUsers()
                      .entries
                      .map(
                        (hospital) => SettingsItem(
                          label: hospital.key.title,
                          subLabel: hospital.value
                              .map(
                                (userAccount) => userAccount.user.fullName,
                              )
                              .join(','),
                          iconWidget: Padding(
                            padding: Paddings.all8,
                            child: SvgPicture.asset(
                              hospital.key.iconPath,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => HospitalUsersScreen(
                                  title: hospital.key.title,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                  SettingsItem(
                    label: context.locale.configuration_screen_add_account,
                    icon: Icons.add,
                    hasNavigationIcon: false,
                    onTap: () {},
                  ),
                  Gaps.gap42,
                  Text(
                    context.locale.configuration_screen_settings,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  Gaps.gap24,
                  SettingsItem(
                    label: context.locale.configuration_screen_notification_label,
                    subLabel: context.locale.configuration_screen_notification_sublabel,
                    icon: Icons.announcement,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const NotificationsSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  Gaps.gap24,
                  SettingsItem(
                    label: context.locale.configuration_screen_appearance_label,
                    subLabel: context.locale.configuration_screen_appearance_sublabel,
                    icon: Icons.imagesearch_roller,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const AppearanceSettingsScreen(),
                        ),
                      );
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
