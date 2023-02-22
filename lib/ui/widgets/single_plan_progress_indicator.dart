import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/widgets/single_progress_indicator.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class SinglePlanProgressIndicator extends StatelessWidget {
  const SinglePlanProgressIndicator({
    super.key,
    required this.carePlan,
    required this.whenPeriod,
  });

  final CarePlan? carePlan;
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

    final progress = carePlan != null
        ? EvaluationPlanHelper.getProgressFromPlans(
            carePlans: [carePlan!],
            offlineResults: offlineResults,
            whenPeriod: whenPeriod,
          )
        : 0;

    return SingleProgressIndicator(
      progress: progress ?? 0,
    );
  }
}
