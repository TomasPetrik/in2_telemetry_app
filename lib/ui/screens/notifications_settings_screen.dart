import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc_event.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/switch_row.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = getIt<SettingsBloc>();
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: Paddings.horizontal16,
                child: BlocBuilder<SettingsBloc, AppSettings>(
                  bloc: settingsBloc,
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(
                          MediaQuery.of(context).viewPadding.top +
                              Constants.appBarHeight,
                        ),
                        Gaps.gap16,
                        SwitchRow.title(
                          title: context
                              .locale.notifications_screen_allow_notifications,
                          defaultValue: state.enabledNotifications,
                          onChanged: (turnedOn) {
                            settingsBloc.add(
                              SettingsBlocEvent.enableNotifications(
                                turnedOn,
                              ),
                            );
                          },
                        ),
                        Gaps.gap24,
                        if (state.enabledNotifications == true) ...[
                          SizedBox(
                            height: 40,
                            child: Text(
                              context.locale.notifications_screen_measurements,
                              style: ScaleTextStyles.textAccent.apply(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          Gaps.gap24,
                          SwitchRow.text(
                            title: context.locale
                                .notifications_screen_at_start_of_measurement,
                            defaultValue: state.notifyAtStartOfMeasurement,
                            onChanged: (turnedOn) {
                              settingsBloc.add(
                                SettingsBlocEvent.notifyAtStartOfMeasurement(
                                  turnedOn,
                                ),
                              );
                            },
                          ),
                          SwitchRow.text(
                            title: context.locale
                                .notifications_screen_10_min_before_measurement,
                            defaultValue: state.notify10minBeforeMeasurement,
                            onChanged: (turnedOn) {
                              settingsBloc.add(
                                SettingsBlocEvent.notify10MinBeforeMeasurement(
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
              title: context.locale.notifications_screen_title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
