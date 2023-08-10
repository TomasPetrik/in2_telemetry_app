import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/appearance_route.dart';
import 'package:scalesoft_app/ui/routers/routes/hospital_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_route.dart';
import 'package:scalesoft_app/ui/routers/routes/notification_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_detail_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/image_widget.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class ConfigurationScreen extends StatelessWidget with BottomSheetMixin {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountDbProvider accountDbProvider = getIt<AccountDbProvider>();
    final hospitalUserEntries = accountDbProvider.getHospitalUsersMap().entries;

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
                      Gap(
                        MediaQuery.of(context).viewPadding.top +
                            Dimensions.appBarHeight,
                      ),
                      Gaps.gap16,
                      Center(
                        child: Image.asset(
                          'assets/images/app_icon_64.png',
                        ),
                      ),
                      Gaps.gap42,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localization.configuration_screen_logged_accounts,
                            style: ScaleTextStyles.textAccent.apply(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final hospitalSelection =
                                  await selectHospital(context: context);
                              if (hospitalSelection?.action ==
                                  SwitchUserAction.addUserAccount) {
                                getIt<AuthBloc>().add(
                                  Authenticate(
                                    hospital:
                                        hospitalSelection!.selectedHospital!,
                                  ),
                                );
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
                      BlocBuilder<SyncBloc, SyncState>(
                        bloc: getIt<SyncBloc>(),
                        builder: (context, state) {
                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final hospital =
                                  hospitalUserEntries.toList()[index];

                              final bool showWarning = hospital.value.any(
                                (userAccount) =>
                                    getIt<Session>()
                                        .getProblemIfExists(userAccount) !=
                                    null,
                              );

                              return SettingsItem(
                                key: ObjectKey(hospital),
                                showWarning: showWarning,
                                label: hospital.key.title,
                                subLabel: '${hospital.value[0].user.fullName}'
                                    ' ${hospital.value.length > 1 ? localization.common_plus_n_others(hospital.value.length - 1) : ''}',
                                iconWidget: Padding(
                                  padding: Paddings.all8,
                                  child: ImageWidget(hospital.key.iconPath),
                                ),
                                iconBackground: ScaleColorsLight.content20,
                                onTap: () {
                                  if (hospital.value.length == 1) {
                                    GoRouter.of(context).pushNamed(
                                      UserDetailRoute.name,
                                      extra: hospital.value[0].user.muid,
                                    );
                                  } else {
                                    GoRouter.of(context).pushNamed(
                                      HospitalDetailRoute.name,
                                      extra: List.of([
                                        hospital.key.title,
                                        accountDbProvider
                                            .getRootUsersFromHospital(
                                              hospital.key,
                                            )
                                            .map(
                                              (userAcccount) =>
                                                  userAcccount.user.muid,
                                            )
                                            .toList(),
                                      ]),
                                    );
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, __) {
                              return Gaps.gap24;
                            },
                            itemCount: hospitalUserEntries.length,
                          );
                        },
                      ),
                      Gaps.gap24,
                      SettingsItem(
                        label: localization.configuration_screen_add_account,
                        iconWidget: SvgPicture.asset(
                          'assets/icons/icon_plus.svg',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        hasNavigationIcon: false,
                        onTap: () async {
                          final hospitalSelection =
                              await selectHospital(context: context);
                          if (hospitalSelection?.action ==
                              SwitchUserAction.addUserAccount) {
                            getIt<AuthBloc>().add(
                              Authenticate(
                                hospital: hospitalSelection!.selectedHospital!,
                              ),
                            );
                          }
                        },
                      ),
                      Gaps.gap42,
                      Text(
                        localization.configuration_screen_settings,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      Gaps.gap24,
                      SettingsItem(
                        label: localization
                            .configuration_screen_notification_label,
                        subLabel: localization
                            .configuration_screen_notification_sublabel,
                        iconWidget: SvgPicture.asset(
                          'assets/icons/icon_message_square_notification.svg',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed(NotificationRoute.name);
                        },
                      ),
                      Gaps.gap24,
                      BlocBuilder<AppSettingsBloc, AppSettings>(
                        bloc: getIt<AppSettingsBloc>()
                          ..add(const AppSettingsBlocEvent.initSettings()),
                        builder: (context, state) {
                          return SettingsItem(
                            label: localization
                                .configuration_screen_appearance_label,
                            subLabel: state.autosetAppearance == true
                                ? localization
                                    .configuration_screen_auto_appearance_sublabel
                                : localization
                                    .configuration_screen_system_appearance_sublabel,
                            iconWidget: SvgPicture.asset(
                              'assets/icons/icon_paint_roller.svg',
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed(AppearanceRoute.name);
                            },
                          );
                        },
                      ),
                      Gaps.gap24,
                      BlocBuilder<AppSettingsBloc, AppSettings>(
                        bloc: getIt<AppSettingsBloc>()
                          ..add(const AppSettingsBlocEvent.initSettings()),
                        builder: (context, state) {
                          return SettingsItem(
                            label: localization.manual_screen_title,
                            subLabel: localization.open_manual_button,
                            iconWidget: SvgPicture.asset(
                              'assets/icons/icon_question.svg',
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            onTap: () {
                              GoRouter.of(context).pushNamed(ManualRoute.name);
                            },
                          );
                        },
                      ),
                      FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: ((context, snapshot) {
                          final packageInfo = snapshot.data;
                          if (packageInfo == null) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              Gaps.gap24,
                              Center(
                                child: Text(
                                  localization.app_version(packageInfo.version),
                                  style: ScaleTextStyles.label.apply(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      Gaps.gap24,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BluredScaleAppBar(
                  title: localization.common_app_name,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
