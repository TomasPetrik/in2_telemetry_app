import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';

class EvaluationPlanHelper {
  static int getProgressFromFullPlanEvaluation({
    required CarePlan carePlan,
    required List<Measurement> offlineResults,
  }) {
    int actualCount = carePlan.fullPlanEvaluation.measurementInPlanCount;
    int requiredMeasurementCount = carePlan.fullPlanEvaluation.requiredMeasurementCount;

    int offlineResultsCount = 0;

    if (offlineResults.isNotEmpty) {
      //get all planned measurements within current time since plan exists
      final allPlannedMeasurements = CarePlanHelper.getPlannedMeasurementsUpToToday(
        carePlan,
        offlineResults,
      );

      //check if offline results are included in these measurements
      final allLegitDateTimes = allPlannedMeasurements.fold<List<DateTime>>(
        [],
        (prevDateTimes, plMeasurement) => [
          ...prevDateTimes,
          ...plMeasurement.fulfillmentEvaluationItem!.actualMeasurementTimes,
        ],
      ).toSet();
      offlineResultsCount = allLegitDateTimes
          .where(
            (legitDt) => offlineResults.any(
              (offlineResult) => offlineResult.measuredAt.isAtSameMomentAs(legitDt),
            ),
          )
          .length;
    }

    int allActualCount = actualCount + offlineResultsCount;
    requiredMeasurementCount = allActualCount > requiredMeasurementCount ? allActualCount : requiredMeasurementCount;

    int percentage = requiredMeasurementCount == 0 ? 0 : (allActualCount / requiredMeasurementCount * 100).round();
    return percentage;
  }

  static int? getProgressFromPlans({
    required List<CarePlan> carePlans,
    required ResultsWhenPeriod whenPeriod,
    required List<Measurement> offlineResults,
  }) {
    int expectedCount = 0;
    int actualCount = 0;

    final List<PlannedMeasurement> plannedMeasurements = ResultsHelper.getPlannedMeasurements(
      carePlans,
      whenPeriod,
      null,
      offlineResults,
    );

    for (final plannedMeasurement in plannedMeasurements) {
      expectedCount += plannedMeasurement.reqCount;
      actualCount += plannedMeasurement.currentCount == null
          ? 0
          : plannedMeasurement.currentCount! > plannedMeasurement.reqCount
              ? plannedMeasurement.reqCount
              : plannedMeasurement.currentCount!;
    }

    return expectedCount == 0 ? null : (actualCount / expectedCount * 100).round();
  }

  static int getProgressFromEvaluationItems(
    List<FulfillmentEvaluationItem> items,
  ) {
    if (items.isEmpty) return 0;

    //1. Get required count
    final allRequiredMeasurementCount =
        items.map((evItem) => evItem.requiredMeasurementCount).reduce((prevVal, nextVal) => prevVal + nextVal);

    //1. Get current measurement count
    final measurementTimes = items.fold<List<DateTime>>(
      [],
      (prevEvTimes, evItem) => [
        ...prevEvTimes,
        ...evItem.actualMeasurementTimes,
      ],
    );

    //2. Make sure they are unique
    final measurementTimesSet = measurementTimes.toSet();
    final allActualMeasurementCount = measurementTimesSet.length;

    return (allActualMeasurementCount / allRequiredMeasurementCount * 100).round();
  }
}
