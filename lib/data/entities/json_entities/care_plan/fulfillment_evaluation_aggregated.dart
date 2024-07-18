import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fulfillment_evaluation_aggregated.g.dart';

@JsonSerializable()
class FulfillmentEvaluationAggregated {
  DateTime? start;
  DateTime? end;
  int requiredMeasurementCount;
  int totalMeasurementCount;
  int measurementInPlanCount;

  FulfillmentEvaluationAggregated(
    this.start,
    this.end,
    this.requiredMeasurementCount,
    this.totalMeasurementCount,
    this.measurementInPlanCount,
  );

  factory FulfillmentEvaluationAggregated.fromJson(Map<String, dynamic> json) =>
      _$FulfillmentEvaluationAggregatedFromJson(json);

  Map<String, dynamic> toJson() => _$FulfillmentEvaluationAggregatedToJson(this);
}

class FulfillmentEvaluationAggregatedConverter extends TypeConverter<FulfillmentEvaluationAggregated, String> {
  const FulfillmentEvaluationAggregatedConverter();

  @override
  FulfillmentEvaluationAggregated fromSql(String fromDb) {
    return FulfillmentEvaluationAggregated.fromJson(
      json.decode(fromDb) as Map<String, dynamic>,
    );
  }

  @override
  String toSql(FulfillmentEvaluationAggregated value) {
    return json.encode(value.toJson());
  }
}
