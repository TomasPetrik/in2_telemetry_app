import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/onboarding_item_desc.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with BottomSheetMixin, WidgetsBindingObserver {
  final notificationsBloc = getIt<NotificationsBloc>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      notificationsBloc
          .add(const NotificationsEvent.setNotificationsBySystemSettings());
    }
  }

  @override
  void initState() {
    notificationsBloc.add(const NotificationsEvent.initSettings());
    if(Platform.isAndroid){
      notificationsBloc
          .add(const NotificationsEvent.setNotificationsBySystemSettings());
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      bloc: notificationsBloc,
      listener: (context, state) {
        if (state == const NotificationsState.denied()) {
          showNotificationsSettings(context: context)
              .then((openNotificationSettings) async {
            if (openNotificationSettings == true) {
              await AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Gap(
                          MediaQuery.of(context).viewPadding.top +
                              Dimensions.appBarHeight,
                        ),
                        Gaps.gap48,
                        SvgPicture.asset(
                          'assets/icons/icon_onboard_user.svg',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        Gaps.gap36,
                        Text(
                          localization
                              .onboarding_add_account_screen_add_account_subtitle,
                          textAlign: TextAlign.center,
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        Gaps.gap24,
                        OnboardingItemDesc(
                          imagePath: 'assets/icons/icon_hospital_user.svg',
                          desc: localization
                              .onboarding_add_account_screen_add_account_text1,
                        ),
                        OnboardingItemDesc(
                          imagePath: 'assets/icons/icon_shield_keyhole.svg',
                          desc: localization
                              .onboarding_add_account_screen_add_account_text2,
                        ),
                        OnboardingItemDesc(
                          imagePath: 'assets/icons/icon_wave_pulse.svg',
                          desc: localization
                              .onboarding_add_account_screen_add_account_text3,
                        ),
                        Gaps.gap24,
                        HighlightedElevatedButton(
                          label: localization
                              .onboarding_add_account_screen_add_account_button,
                          onPressed: () async {
                            final hospitalSelection =
                                await selectHospital(context: context);
                            if (hospitalSelection?.selectedHospital != null) {
                              getIt<AuthBloc>().add(
                                Authenticate(
                                  hospital:
                                      hospitalSelection!.selectedHospital!,
                                ),
                              );
                            }
                          },
                        ),
                        Gaps.gap24,
                        HighlightedElevatedButton(
                          label: localization.open_manual_button,
                          buttonType: ButtonType.secondary,
                          onPressed: () async {
                            GoRouter.of(context).pushNamed(ManualRoute.name);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BlurredScaleAppBar(
                  title: localization
                      .onboarding_add_account_screen_add_account_title,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
