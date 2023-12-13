import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/image_widget.dart';

class UserAddedScreen extends StatelessWidget with BottomSheetMixin {
  const UserAddedScreen({
    super.key,
    required this.userAccount,
  });

  final UserAccount userAccount;

  @override
  Widget build(BuildContext context) {
    final notificationsBloc = getIt<NotificationsBloc>()
      ..add(const NotificationsEvent.initSettings());
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            left: 16,
            right: 16,
            child: Column(
              children: [
                Gap(
                  MediaQuery.of(context).viewPadding.top +
                      Dimensions.appBarHeight,
                ),
                Gaps.gap48,
                Container(
                  width: 96,
                  height: 96,
                  padding: Paddings.all8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadii.radius8,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: ImageWidget(
                    userAccount.hospital!.iconPath,
                  ),
                ),
                Gaps.gap24,
                Padding(
                  padding: const EdgeInsets.only(
                    left: Dimensions.padding48,
                    right: Dimensions.padding48,
                  ),
                  child: Text(
                    localization.onboarding_account_added_screen_user_added(
                      userAccount.user.fullName,
                    ),
                    style: ScaleTextStyles.text.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Gaps.gap24,
                BlocConsumer<NotificationsBloc, NotificationsState>(
                  bloc: notificationsBloc,
                  listener: (context, state) {
                    if (state == const NotificationsState.denied()) {
                      showNotificationsSettings(context: context)
                          .then((openNotificationSettings) async {
                        if (openNotificationSettings == true) {
                          await AppSettings.openAppSettings(
                            type: AppSettingsType.notification,
                          );
                          notificationsBloc.add(
                            const NotificationsEvent.enableNotifications(
                              true,
                            ),
                          );
                        } else {
                          getIt<ContentBloc>().add(
                            SwitchUserContentEvent(userAccount: userAccount),
                          );
                        }
                      });
                    } else if (state == const NotificationsState.granted()) {
                      getIt<ContentBloc>().add(
                        SwitchUserContentEvent(userAccount: userAccount),
                      );
                    }
                  },
                  builder: (context, state) {
                    final appSettings = state.whenOrNull(
                      loaded: (_, appSettings, __) => appSettings,
                    );
                    final timeStamp = state.whenOrNull(
                          loaded: (timeStamp, _, __) => timeStamp,
                        ) ??
                        0;

                    final notificationsGranted = state.whenOrNull(
                          loaded: (timeStamp, _, notificationsGranted) =>
                              notificationsGranted == true,
                        ) ??
                        false;

                    if (appSettings == null) {
                      return const SizedBox.shrink();
                    }

                    return HighlightedElevatedButton(
                      key: ValueKey(timeStamp),
                      label: localization
                          .onboarding_account_added_screen_continue_to_app,
                      onPressed: () async {
                        if (!notificationsGranted) {
                          notificationsBloc.add(
                            const NotificationsEvent.enableNotifications(
                              true,
                            ),
                          );
                        } else {
                          getIt<ContentBloc>().add(
                            SwitchUserContentEvent(userAccount: userAccount),
                          );
                        }
                      },
                    );
                  },
                ),
                Gaps.gap24,
                HighlightedElevatedButton(
                  label: localization
                      .onboarding_account_added_screen_add_other_account,
                  buttonType: ButtonType.secondary,
                  onPressed: () async {
                    final hospitalSelection =
                        await selectHospital(context: context);
                    if (hospitalSelection?.selectedHospital != null) {
                      getIt<AuthBloc>().add(
                        Authenticate(
                          hospital: hospitalSelection!.selectedHospital!,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BluredScaleAppBar(
              title: localization
                  .onboarding_account_added_screen_add_account_title,
            ),
          ),
        ],
      ),
    );
  }
}
