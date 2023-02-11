import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';

class EvaluationPlanHelper {
  
  static int getProgressFromEvaluation(
    FulfillmentEvaluation fulfillmentEvaluation,
  ) {
    return _calculateProgress(fulfillmentEvaluation.items);
  }

  static int getProgressFromPlan(List<CarePlan> carePlans) {
    final List<FulfillmentEvaluationItem> items = [];

    for (final carePlan in carePlans) {
      items.addAll(
        [
          if (carePlan.fulfillmentEvaluation?.items.isNotEmpty == true)
            ...carePlan.fulfillmentEvaluation!.items
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
