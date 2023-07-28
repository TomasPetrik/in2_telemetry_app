import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/measurement_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:sliver_tools/sliver_tools.dart';

class MeasurementsList extends StatelessWidget {
  const MeasurementsList({
    super.key,
    required this.whenPeriod,
    required this.carePlans,
    required this.measurements,
    required this.nextMeasurement,
    required this.planWhenPeriod,
    required this.results,
  });

  final PlanWhenPeriod whenPeriod;
  final List<CarePlan> carePlans;
  final List<PlannedMeasurement> measurements;
  final PlannedMeasurement nextMeasurement;
  final PlanWhenPeriod planWhenPeriod;
  final List<MeasurementResult> results;

  List<PlannedMeasurement> get _pMeasurements => measurements
      .where(
        (measurement) => measurement.isLongPeriod,
      )
      .toList();

  List<PlannedMeasurement> get _rMeasurements => measurements
      .where(
        (measurement) => !measurement.isLongPeriod,
      )
      .toList();

  bool _isTodaysPlanFinished() {
    return measurements.isEmpty &&
        whenPeriod == PlanWhenPeriod.today &&
        CarePlanHelper.hasMeasurementsToday(nextMeasurement.carePlan);
  }

  int _getPlanEvaluation() {
    return EvaluationPlanHelper.getProgressFromPlans(
          carePlans: carePlans,
          whenPeriod: whenPeriod == PlanWhenPeriod.today
              ? ResultsWhenPeriod.today
              : ResultsWhenPeriod.yesterday,
          offlineResults: results,
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return _isTodaysPlanFinished()
        ? SliverPadding(
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
                      localization.dashboard_screen_upcoming_measurement_info(
                    nextMeasurement.whenStart.toDateOrDay().toLowerCase(),
                    nextMeasurement.whenStart.toTimeOfDay().toString(),
                  ),
                ),
              )
            : MultiSliver(
                children: [
                  if (_pMeasurements.isNotEmpty) ...[
                    const SliverGap(Dimensions.padding24),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Paddings.left16,
                        child: Text(
                          localization
                              .dashboard_screen_periodical_measurements,
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
                                plannedMeasurement: _pMeasurements[index],
                              ),
                              if (index != (_pMeasurements.length - 1) ||
                                  (index == (_pMeasurements.length - 1) &&
                                      _rMeasurements.isNotEmpty))
                                Container(
                                  margin: Paddings.horizontal16,
                                  height: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            ],
                          );
                        },
                        childCount: _pMeasurements.length,
                      ),
                    ),
                  ],
                  if (_rMeasurements.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          bool isSameDate = true;

                          final date = _rMeasurements[index].whenStart;

                          if (index == 0) {
                            isSameDate = false;
                          } else {
                            final prevDate =
                                _rMeasurements[index - 1].whenStart;
                            isSameDate = date.isSameDate(prevDate);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (planWhenPeriod != PlanWhenPeriod.next10 &&
                                  _pMeasurements.isNotEmpty &&
                                  index == 0) ...[
                                Gaps.gap24,
                                Padding(
                                  padding: Paddings.left16,
                                  child: Text(
                                    localization.common_measurement_times(
                                      planWhenPeriod.name,
                                    ),
                                    style: ScaleTextStyles.label.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ),
                                Gaps.gap8,
                              ] else if ((planWhenPeriod ==
                                      PlanWhenPeriod.next10 &&
                                  !(isSameDate))) ...[
                                Gaps.gap24,
                                Padding(
                                  padding: Paddings.left16,
                                  child: Text(
                                    date.toDateOrDay(),
                                    style: ScaleTextStyles.label.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ),
                                Gaps.gap8,
                              ],
                              MeasurementItem(
                                plannedMeasurement: _rMeasurements[index],
                              ),
                              if (index != (_rMeasurements.length - 1))
                                Container(
                                  margin: Paddings.horizontal16,
                                  height: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            ],
                          );
                        },
                        childCount: _rMeasurements.length,
                      ),
                    ),
                ],
              );
  }
}
