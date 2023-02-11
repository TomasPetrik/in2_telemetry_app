import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'fulfillment_evaluation.freezed.dart';
part 'fulfillment_evaluation.g.dart';

@freezed
class FulfillmentEvaluation with _$FulfillmentEvaluation {
  const FulfillmentEvaluation._();

  @HiveType(typeId: 21, adapterName: 'FulfillmentEvaluationAdapter')
  const factory FulfillmentEvaluation(
    @HiveField(0) List<FulfillmentEvaluationItem> items,
  ) = _FulfillmentEvaluation;

  factory FulfillmentEvaluation.fromJson(Map<String, dynamic> json) =>
      _$FulfillmentEvaluationFromJson(json);

  @override
  String toString() => toJson().toString();
}

@freezed
class FulfillmentEvaluationItem with _$FulfillmentEvaluationItem {
  @HiveType(typeId: 22, adapterName: 'FulfillmentEvaluationItemAdapter')
  factory FulfillmentEvaluationItem(
    @HiveField(0) DateTime start,
    @HiveField(1) DateTime end,
    @HiveField(2) int requiredMeasurementCount,
    @HiveField(3) int actualMeasurementCount,
  ) = _FulfillmentEvaluationItem;

  factory FulfillmentEvaluationItem.fromJson(Map<String, dynamic> json) =>
      _$FulfillmentEvaluationItemFromJson(json);

  @override
  String toString() => toJson().toString();
}
