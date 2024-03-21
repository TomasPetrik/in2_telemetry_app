import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fulfillment_evaluation_item.g.dart';

@JsonSerializable()
class FulfillmentEvaluationItem {
  DateTime start;
  DateTime end;
  int requiredMeasurementCount;
  int actualMeasurementCount;
  List<DateTime> actualMeasurementTimes;

  FulfillmentEvaluationItem(
    this.start,
    this.end,
    this.requiredMeasurementCount,
    this.actualMeasurementCount,
    this.actualMeasurementTimes,
  );

  factory FulfillmentEvaluationItem.fromJson(Map<String, dynamic> json) => _$FulfillmentEvaluationItemFromJson(json);

  Map<String, dynamic> toJson() => _$FulfillmentEvaluationItemToJson(this);
}

class FulfillmentEvaluationItemListConverter extends TypeConverter<List<FulfillmentEvaluationItem>, String> {
  const FulfillmentEvaluationItemListConverter();

  @override
  List<FulfillmentEvaluationItem> fromSql(String fromDb) {
    return jsonDecode(fromDb)
        .cast<Map<String, dynamic>>()
        .map<FulfillmentEvaluationItem>(FulfillmentEvaluationItem.fromJson)
        .toList();
  }

  @override
  String toSql(List<FulfillmentEvaluationItem> value) {
    return json.encode(value);
  }
}
