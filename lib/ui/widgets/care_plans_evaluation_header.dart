import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/single_plan_progress_indicator.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class CarePlansEvaluationHeader extends StatelessWidget {
  const CarePlansEvaluationHeader({
    super.key,
    required this.carePlans,
    required this.whenPeriod,
    required this.openTimeSelector,
  });

  final List<CarePlan> carePlans;
  final ResultsWhenPeriod whenPeriod;
  final Function openTimeSelector;

  @override
  Widget build(BuildContext context) {
    final supportedMeasurementTypes =
        CarePlanHelper.getMeasurementTypes(carePlans);

    final itemWidth =
        (MediaQuery.of(context).size.width - (4 * Dimensions.padding16)) / 4;

    return SliverToBoxAdapter(
      child: Container(
        margin: Paddings.horizontal16,
        width: double.maxFinite,
        padding: Paddings.all16,
        decoration: BoxDecoration(
          borderRadius: BorderRadii.radius16,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_chart_pie_simple.svg',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                Gaps.gap16,
                Text(
                  context.locale.common_plan_fulfillment,
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    openTimeSelector.call();
                  },
                  child: Text(
                    context.locale.common_measurement_times(whenPeriod.name),
                    style: ScaleTextStyles.text.apply(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Gaps.gap16,
            if (supportedMeasurementTypes.length <= 1) ...{
              Builder(
                builder: (context) {
                  return SinglePlanProgressIndicator(
                    carePlan: carePlans.firstOrNull,
                    whenPeriod: whenPeriod,
                  );
                },
              )
            } else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...supportedMeasurementTypes
                        .map(
                          (measurementType) => SizedBox(
                            width: itemWidth,
                            child: _CircularPlansEvaluationProgress(
                              measurementType: measurementType,
                              carePlans: carePlans
                                  .where(
                                    (carePlan) =>
                                        carePlan.activity.measurementType ==
                                        measurementType,
                                  )
                                  .toList(),
                              whenPeriod: whenPeriod,
                            ),
                          ),
                        )
                        .toList(),
                    if (supportedMeasurementTypes.length > 1) ...{
                      SizedBox(
                        width: itemWidth,
                        child: _CircularPlansEvaluationProgress(
                          measurementType: null,
                          carePlans: carePlans,
                          whenPeriod: whenPeriod,
                        ),
                      ),
                    },
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircularPlansEvaluationProgress extends StatelessWidget {
  const _CircularPlansEvaluationProgress({
    required this.measurementType,
    required this.carePlans,
    required this.whenPeriod,
  });

  final MeasurementType? measurementType;
  final List<CarePlan> carePlans;
  final ResultsWhenPeriod whenPeriod;

  @override
  Widget build(BuildContext context) {
    final allPendingResults = getIt<Session>().getPendingResults();

    final List<MeasurementResult> offlineResults =
        MeasurementHelper.getOffilneResultsConverted(
      allPendingResults,
      [whenPeriod],
      null,
    );

    final progress = EvaluationPlanHelper.getProgressFromPlans(
      carePlans: carePlans,
      offlineResults: offlineResults,
      whenPeriod: whenPeriod,
    );

    return _CircularIndicator(
      label: measurementType == null
          ? context.locale.common_overall
          : context.locale.common_measurement_types(
              measurementType!.name,
            ),
      percent: progress / 100,
    );
  }
}

class _CircularIndicator extends StatelessWidget {
  const _CircularIndicator({
    required this.label,
    required this.percent,
  });

  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 18,
      lineWidth: 8,
      //animation: true,
      percent: percent,
      footer: Padding(
        padding: Paddings.top5,
        child: Text(
          label,
          style: ScaleTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      progressColor: Theme.of(context).colorScheme.onError,
    );
  }
}
