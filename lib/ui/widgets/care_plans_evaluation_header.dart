import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/no_results_in_plans_header.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class CarePlansEvaluationHeader extends StatelessWidget {
  const CarePlansEvaluationHeader({
    super.key,
    required this.carePlans,
    required this.whenPeriod,
    required this.openWhenSelector,
  });

  final List<CarePlan> carePlans;
  final ResultsWhenPeriod whenPeriod;
  final Function openWhenSelector;

  @override
  Widget build(BuildContext context) {
    final supportedMeasurementTypes =
        CarePlanHelper.getMeasurementTypes(carePlans);

    final allPendingResults = getIt<Session>().getPendingResults();

    final List<MeasurementResult> offlineResults =
        MeasurementHelper.getOffilneResultsConverted(
      allPendingResults,
      [whenPeriod],
      null,
    );

    List<ProgressItem> progressItems = [];

    for (final measurementType in supportedMeasurementTypes) {
      final typedPlans = carePlans
          .where(
            (carePlan) => carePlan.activity.measurementType == measurementType,
          )
          .toList();

      final progress = EvaluationPlanHelper.getProgressFromPlans(
        carePlans: typedPlans,
        offlineResults: offlineResults,
        whenPeriod: whenPeriod,
      );

      if (progress != null) {
        progressItems.add(
          ProgressItem(
            localization.common_measurement_types(measurementType.name),
            progress,
          ),
        );
      }
    }

    if (supportedMeasurementTypes.length > 1) {
      final progress = EvaluationPlanHelper.getProgressFromPlans(
        carePlans: carePlans,
        offlineResults: offlineResults,
        whenPeriod: whenPeriod,
      );

      if (progress != null) {
        progressItems.add(
          ProgressItem(
            localization.common_overall,
            progress,
          ),
        );
      }
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Gaps.gap16,
          progressItems.isEmpty
              ? NoResultsInPlansHeader(
                  whenPeriod: whenPeriod,
                  openWhenSelector: openWhenSelector,
                )
              : ProgressHeader(
                  whenPeriod: whenPeriod,
                  openWhenSelector: openWhenSelector,
                  progressItems: progressItems,
                  label: localization.common_plans_fulfillment_plural(
                    progressItems.length,
                  ),
                ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
