import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'fulfillment_evaulation_aggregated.freezed.dart';
part 'fulfillment_evaulation_aggregated.g.dart';
part 'fulfillment_evaulation_aggregated.hive.dart';

@freezed
class FulfillmentEvaluationAggregated with _$FulfillmentEvaluationAggregated {
  @HiveType(typeId: 23, adapterName: 'FulfillmentEvaluationAggregatedAdapter')
  factory FulfillmentEvaluationAggregated(
    @JsonKey(fromJson: toLocalDate) @HiveField(0) DateTime start,
    @JsonKey(fromJson: toLocalDate) @HiveField(1) DateTime end,
    @HiveField(2) int requiredMeasurementCount,
    @HiveField(3) int totalMeasurementCount,
    @HiveField(4) int measurementInPlanCount,
  ) = _FulfillmentEvaluationAggregated;

  factory FulfillmentEvaluationAggregated.fromJson(Map<String, dynamic> json) =>
      _$FulfillmentEvaluationAggregatedFromJson(json);

  @override
  String toString() => toJson().toString();
}
