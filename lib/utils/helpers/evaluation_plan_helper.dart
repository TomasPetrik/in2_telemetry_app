import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

class EvaluationPlanHelper {
  static int getProgressFromFullPlanEvaluation(
    FulfillmentEvaluationAggregated fullPlanEvaluation,
  ) {
    int actualCount = fullPlanEvaluation.measurementInPlanCount;
    int requiredMeasurementCount = fullPlanEvaluation.requiredMeasurementCount;

    //TODO.. here should be included also offline results if this plan contains planned measurements
    //and their intervals are matching with offline results

    int percentage = requiredMeasurementCount == 0
        ? requiredMeasurementCount
        : (actualCount / requiredMeasurementCount * 100).round();
    return percentage;
  }

  static int getProgressFromEvaluation(
    FulfillmentEvaluation fulfillmentEvaluation,
  ) {
    return _calculateProgress(fulfillmentEvaluation.items);
  }

  static int getProgressFromPlans({
    required List<CarePlan> carePlans,
    required List<MeasurementResult> offlineResults,
    required ResultsWhenPeriod whenPeriod,
  }) {
    final List<FulfillmentEvaluationItem> items = [];

    int expectedCount = 0;
    int actualCount = 0;

    final List<PlannedMeasurement> plannedMeasurements =
        ResultsHelper.getMeasurements(
      carePlans,
      whenPeriod,
      null,
    );

    for (final plannedMeasurement in plannedMeasurements) {
      expectedCount += plannedMeasurement.reqCount;
    }

    //Include fulfillments evaluation items
    for (final carePlan in carePlans) {
      final List<FulfillmentEvaluationItem> carePlanEvaluationItems =
          carePlan.lastTwoDaysEvaluation?.items.isNotEmpty == true
              ? carePlan.lastTwoDaysEvaluation!.items.where((evItem) {
                  if ((whenPeriod == ResultsWhenPeriod.today &&
                          evItem.start.isToday()) ||
                      (whenPeriod == ResultsWhenPeriod.yesterday &&
                          evItem.start.wasYesterday())) {
                    actualCount += evItem.actualMeasurementCount >
                            evItem.requiredMeasurementCount
                        ? evItem.requiredMeasurementCount
                        : evItem.actualMeasurementCount;

                    return true;
                  }
                  return false;
                }).toList()
              : [];

      items.addAll(carePlanEvaluationItems);
    }

    //Include offline results if exists into plan fulfillment evaluation:

    //1. get planned measurements by careplan within current time inlcude ongoing results

    final dtNow = DateTime.now();
    final plannedMeasurementsWithingCurrentTime =
        plannedMeasurements.where((measurement) {
      return measurement.whenStart.isBefore(dtNow);
    }).toList();

    //2. check their expected frequency in interval
    for (final plannedMeasurement in plannedMeasurementsWithingCurrentTime) {
      //3. then look if offline results matching this period and measurementType
      final matchingResultsInPeriod = offlineResults.where((offlineResult) {
        return (offlineResult.measurementType ==
                plannedMeasurement.carePlan.activity.measurementType &&
            plannedMeasurement.hasMeasurementAt(
              offlineResult.measurementDateTime,
            ));
      });

      //4. Add offline measurements count to actualCount with overflow check
      if (matchingResultsInPeriod.isNotEmpty) {
        final maxIntervalCount =
            matchingResultsInPeriod.length > plannedMeasurement.reqCount
                ? plannedMeasurement.reqCount
                : matchingResultsInPeriod.length;
        actualCount += maxIntervalCount;

        items.add(
          FulfillmentEvaluationItem(
            plannedMeasurement.whenStart,
            plannedMeasurement.whenEnd,
            plannedMeasurement.reqCount,
            maxIntervalCount,
          ),
        );
      }
    }

    return expectedCount == 0 ? 0 : (actualCount / expectedCount * 100).round();
  }

  static int _calculateProgress(List<FulfillmentEvaluationItem> items) {
    if (items.isEmpty) return 0;

    int allActualMeasurementCount = items.fold(
      0,
      (sum, current) =>
          sum +
          (current.actualMeasurementCount > current.requiredMeasurementCount
              ? current.requiredMeasurementCount
              : current.actualMeasurementCount),
    );
    int allRequiredMeasurementCount =
        items.fold(0, (sum, current) => sum + current.requiredMeasurementCount);

    return (allActualMeasurementCount / allRequiredMeasurementCount * 100)
        .round();
  }
}
