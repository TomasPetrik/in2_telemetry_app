import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/measurement_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:sliver_tools/sliver_tools.dart';

class MeasurementsList extends StatelessWidget {
  const MeasurementsList({
    super.key,
    required this.whenPeriod,
    required this.carePlans,
    required this.nextMeasurement,
    required this.planWhenPeriod,
    required this.measurementsOfDay,
  });

  final PlanWhenPeriod whenPeriod;
  final List<CarePlan> carePlans;
  final PlannedMeasurement nextMeasurement;
  final PlanWhenPeriod planWhenPeriod;
  final List<MeasurementResultViewModel> measurementsOfDay;

  List<MeasurementResultViewModel> get upcomingMeasurements {
    final now = DateTime.now();

    return measurementsOfDay
        .where((x) => x.wasPlanned)
        .where((x) => x.requiredCount > x.actualCount)
        .where((x) => (x.measurementIntervalEnd ?? x.measurementTime).isAfter(now))
        .toList();
  }

  List<MeasurementResultViewModel> get _multiDayMeasurements =>
      upcomingMeasurements.where((measurement) => measurement.spansMultipleDays).toList();

  List<MeasurementResultViewModel> get _singleDayMeasurements =>
      upcomingMeasurements.where((measurement) => !measurement.spansMultipleDays).toList();

  bool _isTodaysPlanFinished() {
    return upcomingMeasurements.isEmpty &&
        whenPeriod == PlanWhenPeriod.today &&
        measurementsOfDay.any((x) => x.wasPlanned);
  }

  int _getPlanEvaluation() {
    var expectedCount = 0;
    var actualCount = 0;

    for (final measurement in measurementsOfDay.where((x) => x.wasPlanned)) {
      expectedCount += measurement.requiredCount;
      actualCount += [measurement.requiredCount, measurement.actualCount].min;
    }

    return expectedCount == 0 ? 0 : (actualCount / expectedCount * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTodaysPlanFinished()) {
      return SliverPadding(
        padding: Paddings.horizontal64,
        sliver: InfoPlaceholder(
          icon: SvgPicture.asset(
            'assets/icons/icon_circle_check_big.svg',
            color: Theme.of(context).colorScheme.onTertiary,
          ),
          label: localization.dashboard_screen_todays_plan_finished(
            _getPlanEvaluation(),
          ),
        ),
      );
    }

    if (upcomingMeasurements.isEmpty) {
      return SliverPadding(
        padding: Paddings.horizontal64,
        sliver: InfoPlaceholder(
          icon: SvgPicture.asset(
            'assets/icons/icon_snooze_big.svg',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          label: localization.dashboard_screen_upcoming_measurement_info(
            nextMeasurement.whenStart.toDateOrDay().toLowerCase(),
            nextMeasurement.whenStart.toTimeOfDay().toString(),
          ),
        ),
      );
    }

    return MultiSliver(
      children: [
        if (_multiDayMeasurements.isNotEmpty) ...[
          const SliverGap(Dimensions.padding24),
          SliverToBoxAdapter(
            child: Padding(
              padding: Paddings.left16,
              child: Text(
                localization.multi_day_measurements,
                style: ScaleTextStyles.label.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SliverGap(Dimensions.padding8),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeasurementItem(
                      measurement: _multiDayMeasurements[index],
                    ),
                    if (index != (_multiDayMeasurements.length - 1) ||
                        (index == (_multiDayMeasurements.length - 1) && _singleDayMeasurements.isNotEmpty))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: _multiDayMeasurements.length,
            ),
          ),
        ],
        if (_singleDayMeasurements.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                bool isSameDate = true;

                final item = _singleDayMeasurements[index];

                final date = item.measurementIntervalStart ?? item.measurementTime;

                if (index == 0) {
                  isSameDate = false;
                } else {
                  final previousItem = _singleDayMeasurements[index - 1];
                  final previousDate = previousItem.measurementIntervalStart ?? previousItem.measurementTime;
                  isSameDate = date.isSameDate(previousDate);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (planWhenPeriod != PlanWhenPeriod.next10 && _multiDayMeasurements.isNotEmpty && index == 0) ...[
                      Gaps.gap24,
                      Padding(
                        padding: Paddings.left16,
                        child: Text(
                          localization.common_measurement_times(
                            planWhenPeriod.name,
                          ),
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      Gaps.gap8,
                    ] else if ((planWhenPeriod == PlanWhenPeriod.next10 && !(isSameDate))) ...[
                      Gaps.gap24,
                      Padding(
                        padding: Paddings.left16,
                        child: Text(
                          date.toDateOrDay(),
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      Gaps.gap8,
                    ],
                    MeasurementItem(
                      measurement: _singleDayMeasurements[index],
                    ),
                    if (index != (_singleDayMeasurements.length - 1))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: _singleDayMeasurements.length,
            ),
          ),
      ],
    );
  }
}
