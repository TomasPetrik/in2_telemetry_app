import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/appearance_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/hospital_details_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/notifications_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/user_details_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class ConfigurationScreen extends StatelessWidget with BottomSheetMixin {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountDbProvider accountDbProvider = getIt<AccountDbProvider>();

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        bloc: getIt<AuthBloc>(),
        builder: (context, state) {
          return Stack(
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
                            onTap: () async {
                              final hospitalSelection = await selectHospital(context: context);
                              if (hospitalSelection?.action == SwitchUserAction.addUserAccount) {
                                getIt<AuthBloc>().add(Authenticate(hospital: hospitalSelection!.selectedHospital!));
                              }
                            },
                            child: SvgPicture.asset(
                              'assets/icons/icon_plus_large.svg',
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
                              subLabel: '${hospital.value[0].user.fullName}'
                                  ' ${hospital.value.length > 1 ? context.locale.common_plus_n_others(hospital.value.length - 1) : ''}',
                              iconWidget: Padding(
                                padding: Paddings.all8,
                                child: SvgPicture.asset(
                                  hospital.key.iconPath,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              onTap: () {
                                if (hospital.value.length == 1) {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => UserDetailScreen(
                                        userAccount: hospital.value[0],
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => HospitalDetailScreen(
                                        hospital: hospital.key,
                                        userAccounts: hospital.value,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                          .toList(),
                      SettingsItem(
                        label: context.locale.configuration_screen_add_account,
                        iconWidget: SvgPicture.asset(
                          'assets/icons/icon_plus.svg',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        hasNavigationIcon: false,
                        onTap: () async {
                          final hospitalSelection = await selectHospital(context: context);
                          if (hospitalSelection?.action == SwitchUserAction.addUserAccount) {
                            getIt<AuthBloc>().add(Authenticate(hospital: hospitalSelection!.selectedHospital!));
                          }
                        },
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
                        iconWidget: SvgPicture.asset(
                          'assets/icons/icon_message_square_notification.svg',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
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
                        iconWidget: SvgPicture.asset(
                          'assets/icons/icon_paint_roller.svg',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
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
          );
        },
      ),
    );
  }
}
