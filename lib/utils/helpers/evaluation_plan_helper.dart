import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class EvaluationPlanHelper {
  static int getProgressFromEvaluation(
    FulfillmentEvaluation fulfillmentEvaluation,
  ) {
    return _calculateProgress(fulfillmentEvaluation.items);
  }

  static int getProgressFromPlan({
    required List<CarePlan> carePlans,
    ResultsWhenPeriod? whenPeriod,
  }) {
    final List<FulfillmentEvaluationItem> items = [];

    for (final carePlan in carePlans) {
      items.addAll(
        [
          if (carePlan.fulfillmentEvaluation?.items.isNotEmpty == true)
            ...carePlan.fulfillmentEvaluation!.items.where((evItem) {
              if (whenPeriod == null ||
                  (whenPeriod == ResultsWhenPeriod.today &&
                      evItem.start.isToday()) ||
                  (whenPeriod == ResultsWhenPeriod.yesterday &&
                      evItem.start.wasYesterday())) {
                return true;
              }
              return false;
            })
        ],
      );
    }

    return _calculateProgress(items);
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
