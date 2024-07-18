import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/switch_row.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen>
    with BottomSheetMixin, WidgetsBindingObserver {
  final notificationsBloc = getIt<NotificationsBloc>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      notificationsBloc
          .add(const NotificationsEvent.initSettings());
    }
  }

  @override
  void initState() {
    notificationsBloc.add(const NotificationsEvent.initSettings());
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
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: Paddings.horizontal16,
                child: BlocConsumer<NotificationsBloc, NotificationsState>(
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
                  buildWhen: (previous, current) {
                    return current.when(
                      init: () => false,
                      denied: () => false,
                      granted: () => false,
                      loaded: (_, __, ___) => true,
                    );
                  },
                  builder: (context, state) {
                    final appSettings = state.whenOrNull(
                      loaded: (_, appSettings, __) => appSettings,
                    );
                    final timeStamp = state.whenOrNull(
                          loaded: (timeStamp, _, __) => timeStamp,
                        ) ??
                        0;

                    if (appSettings == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      key: ValueKey(timeStamp),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(
                          MediaQuery.of(context).viewPadding.top +
                              Dimensions.appBarHeight,
                        ),
                        Gaps.gap16,
                        SwitchRow.title(
                          title: localization
                              .notifications_screen_allow_notifications,
                          defaultValue: appSettings.enableNotifications,
                          onChanged: (turnedOn) {
                            notificationsBloc.add(
                              NotificationsEvent.enableNotifications(
                                turnedOn,
                              ),
                            );
                          },
                        ),
                        Gaps.gap24,
                        if (appSettings.enableNotifications) ...[
                          SizedBox(
                            height: 40,
                            child: Text(
                              localization.notifications_screen_measurements,
                              style: ScaleTextStyles.textAccent.apply(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          Gaps.gap24,
                          SwitchRow.text(
                            title: localization
                                .notifications_screen_at_start_of_measurement,
                            defaultValue:
                                appSettings.notifyAtStartOfMeasurement,
                            onChanged: (turnedOn) {
                              notificationsBloc.add(
                                NotificationsEvent.notifyAtStartOfMeasurement(
                                  turnedOn,
                                ),
                              );
                            },
                          ),
                          SwitchRow.text(
                            title: localization
                                .notifications_screen_10_min_before_measurement,
                            defaultValue:
                                appSettings.notify10minBeforeMeasurement,
                            onChanged: (turnedOn) {
                              notificationsBloc.add(
                                NotificationsEvent.notify10MinBeforeMeasurement(
                                  turnedOn,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: localization.notifications_screen_title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
