import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';

class FulfillmentEvaluationModel extends FulfillmentEvaluationItem {
  final int carePlanId;
  final int userId;

  FulfillmentEvaluationModel(
    super.start,
    super.end,
    super.requiredMeasurementCount,
    super.actualMeasurementCount,
    super.actualMeasurementTimes,
    this.carePlanId,
    this.userId,
  );

  factory FulfillmentEvaluationModel.fromItem(FulfillmentEvaluationItem item, int carePlanId, int userId) =>
      FulfillmentEvaluationModel(item.start, item.end, item.requiredMeasurementCount, item.actualMeasurementCount,
          item.actualMeasurementTimes, carePlanId, userId);
}
