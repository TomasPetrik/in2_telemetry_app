import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/measurement_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeasurementsList extends StatelessWidget {
  const MeasurementsList({
    super.key,
    required this.measurements,
    required this.nextMeasurement,
    required this.planWhenPeriod,
  });

  final List<PlannedMeasurement> measurements;
  final PlannedMeasurement nextMeasurement;
  final PlanWhenPeriod planWhenPeriod;

  MeasurementNeed getMeasurementNeed(PlannedMeasurement measurement) {
    final dtNow = DateTime.now();

    if (dtNow.isBefore(measurement.whenEnd) &&
        dtNow.isAfter(measurement.whenStart)) {
      return MeasurementNeed.now;
    } else {
      return MeasurementNeed.upcoming;
    }
  }

  bool isTodaysPlanFinished() {
    final todayPlanFinished = measurements.any(
      (measurement) =>
          measurement.carePlan.getTodayRemainingMeasurements().isEmpty &&
          measurement.carePlan.hasMeasurementsToday(),
    );
    return todayPlanFinished;
  }

  @override
  Widget build(BuildContext context) {
    return isTodaysPlanFinished()
        ? SliverPadding(
            padding: Paddings.horizontal64,
            sliver: InfoPlaceholder(
              icon: SvgPicture.asset(
                'assets/icons/icon_circle_check_big.svg',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              label: context.locale.dashboard_screen_todays_plan_finished(
                56,
              ),
            ),
          )
        : measurements.isEmpty
            ? SliverPadding(
                padding: Paddings.horizontal64,
                sliver: InfoPlaceholder(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_snooze_big.svg',
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  label:
                      context.locale.dashboard_screen_upcoming_measurement_info(
                    nextMeasurement.whenStart.toDateOrDay(context),
                    nextMeasurement.timingDayWhen.start.toString(),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, int index) {
                    bool isSameDate = true;

                    final date = measurements[index].whenStart;
                    final timeDayWhen = measurements[index].timingDayWhen;
                    final carePlan = measurements[index].carePlan;

                    if (index == 0) {
                      isSameDate = false;
                    } else {
                      final prevDate = measurements[index - 1].whenStart;
                      isSameDate = date.isSameDate(prevDate);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (planWhenPeriod == PlanWhenPeriod.next10 &&
                            (index == 0 || !(isSameDate))) ...[
                          Gaps.gap24,
                          Padding(
                            padding: Paddings.left16,
                            child: Text(
                              date.toDateOrDay(context),
                              style: ScaleTextStyles.label.apply(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          Gaps.gap8,
                        ],
                        MeasurementItem(
                          timingDayWhen: timeDayWhen,
                          carePlan: carePlan,
                          measurementNeed:
                              getMeasurementNeed(measurements[index]),
                        ),
                        if (index != (measurements.length - 1))
                          Container(
                            margin: Paddings.horizontal16,
                            height: 0.5,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                      ],
                    );
                  },
                  childCount: measurements.length,
                ),
              );
  }
}
