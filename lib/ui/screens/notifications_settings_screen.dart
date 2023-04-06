import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/switch_row.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsBloc = getIt<NotificationsBloc>()
      ..add(const NotificationsEvent.initSettings());
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: Paddings.horizontal16,
                child: BlocBuilder<NotificationsBloc, NotificationsState>(
                  bloc: notificationsBloc,
                  builder: (context, state) {
                    final appSettings = state.whenOrNull(
                      loaded: (appSettings) => appSettings,
                    );

                    if (appSettings == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(
                          MediaQuery.of(context).viewPadding.top +
                              Dimensions.appBarHeight,
                        ),
                        Gaps.gap16,
                        SwitchRow.title(
                          title: translactions
                              .notifications_screen_allow_notifications,
                          defaultValue: appSettings.enabledNotifications,
                          onChanged: (turnedOn) {
                            notificationsBloc.add(
                              NotificationsEvent.enableNotifications(
                                turnedOn,
                              ),
                            );
                          },
                        ),
                        Gaps.gap24,
                        if (appSettings.enabledNotifications == true) ...[
                          SizedBox(
                            height: 40,
                            child: Text(
                              translactions.notifications_screen_measurements,
                              style: ScaleTextStyles.textAccent.apply(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          Gaps.gap24,
                          SwitchRow.text(
                            title: translactions
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
                            title: translactions
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
            child: BluredScaleAppBar(
              title: translactions.notifications_screen_title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
