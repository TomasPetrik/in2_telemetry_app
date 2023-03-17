import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class CalendarDbProvider extends BoxProvider<FulfillmentEvaluation> {
  @override
  final String boxName = 'CalendarBox';

  @override
  void registerAdapters() {}

  FulfillmentEvaluation? get(int carePlanId, int year, int month) {
    final fulfillmentEvaluation = box.get('$carePlanId:$year:$month');
    return fulfillmentEvaluation;
  }

  Future<void> put(
    int carePlanId,
    int year,
    int month,
    FulfillmentEvaluation fulfillmentEvaluation,
  ) async {
    await box.put('$carePlanId:$year:$month', fulfillmentEvaluation);
  }
}
