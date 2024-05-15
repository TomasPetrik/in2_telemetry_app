import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_bloc.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_event.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/ui/widgets/time_setting_row.dart';

class TimesSettingsForm extends StatelessWidget with BottomSheetMixin {
  TimesSettingsForm({
    super.key,
    required this.carePlan,
  });

  final CarePlan carePlan;
  late final TimesSettingsBloc timeSettingsBloc;

  bool settingsChanged() {
    return timeSettingsBloc.settingsChanged == true;
  }

  @override
  Widget build(BuildContext context) {
    timeSettingsBloc = getIt<TimesSettingsBloc>()
      ..add(TimesSettingsEvent.init(carePlan));
    return BlocConsumer<TimesSettingsBloc, TimesSettingsState>(
      bloc: timeSettingsBloc,
      listener: (context, state) {
        state.whenOrNull(errorUpdate: (dateTime) => showServerError(context));
      },
      buildWhen: (previous, current) {
        final isError = current.whenOrNull(errorUpdate: (dateTime) => true);

        return isError == null || isError == false;
      },
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(
            child: LoadingIndicator(),
          ),
          isNotAvailable: () => const SliverGap(0),
          errorUpdate: (dateTime) => const SliverGap(0),
          data: (_, templateWhenValues, timingsDayWhen) {
            return _TimeSettingsForm(
              key: ObjectKey(state),
              timeSettingsBloc: timeSettingsBloc,
              templateWhenValues: templateWhenValues,
              timingsDayWhen: timingsDayWhen,
              carePlan: carePlan,
              resetTimes: () {
                timeSettingsBloc.add(
                  TimesSettingsEvent.resetTimes(
                    carePlan,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TimeSettingsForm extends StatelessWidget with BottomSheetMixin {
  _TimeSettingsForm({
    super.key,
    required this.resetTimes,
    required this.templateWhenValues,
    required this.timingsDayWhen,
    required this.timeSettingsBloc,
    required this.carePlan,
  });

  final VoidCallback resetTimes;
  final List<WhenTemplate> templateWhenValues;
  final List<TimingDayWhen> timingsDayWhen;
  final TimesSettingsBloc timeSettingsBloc;
  final CarePlan carePlan;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: Paddings.horizontal16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.care_plan_detail_daily_times,
                  style: ScaleTextStyles.textAccent.apply(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final confirm = await showResetWhenTimeValuesConfirmation(
                      context: context,
                    );

                    if (confirm == true) {
                      resetTimes.call();
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/icon_dots_horizontal.svg',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Gaps.gap26,
          ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final timingDayWhen = timingsDayWhen[index];

              final templateWhenTime = templateWhenValues.firstWhereOrNull(
                (whenTime) => whenTime.whenCode == timingDayWhen.whenCode,
              );

              return Padding(
                padding: Paddings.horizontal16,
                child: TimeSettingRow(
                  timingDayWhen: timingDayWhen,
                  templateWhenTime: templateWhenTime!,
                  onNewStartTimeSet: (newStartTime) {
                    timeSettingsBloc.add(
                      TimesSettingsEvent.setTime(
                        carePlan: carePlan,
                        newStartTime: newStartTime,
                        newEndTime: timingDayWhen.end,
                        timingDayWhen: timingDayWhen,
                      ),
                    );
                  },
                  onNewEndTimeSet: (newEndTime) {
                    timeSettingsBloc.add(
                      TimesSettingsEvent.setTime(
                        carePlan: carePlan,
                        newStartTime: timingDayWhen.start,
                        newEndTime: newEndTime,
                        timingDayWhen: timingDayWhen,
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Gaps.gap16;
            },
            itemCount: timingsDayWhen.length,
          ),
        ],
      ),
    );
  }
}
