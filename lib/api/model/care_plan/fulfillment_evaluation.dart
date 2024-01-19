import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

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

@unfreezed
class FulfillmentEvaluationItem with _$FulfillmentEvaluationItem {
  FulfillmentEvaluationItem._();

  @HiveType(typeId: 22, adapterName: 'FulfillmentEvaluationItemAdapter')
  factory FulfillmentEvaluationItem(
    @JsonKey(fromJson: toLocalDate) @HiveField(0) DateTime start,
    @JsonKey(fromJson: toLocalDate) @HiveField(1) DateTime end,
    @HiveField(2) int requiredMeasurementCount,
    @HiveField(3) int actualMeasurementCount,
    @HiveField(4)
    @MeasurementTimesConverter()
        List<DateTime> actualMeasurementTimes,
  ) = _FulfillmentEvaluationItem;

  factory FulfillmentEvaluationItem.fromJson(Map<String, dynamic> json) =>
      _$FulfillmentEvaluationItemFromJson(json);

  @override
  String toString() => toJson().toString();

  bool wasMeasured() => actualMeasurementCount >= requiredMeasurementCount;
}

class MeasurementTimesConverter
    implements JsonConverter<List<DateTime>, List<dynamic>> {
  const MeasurementTimesConverter();

  @override
  List<DateTime> fromJson(List<dynamic> measurementUtcTimesJson) {
    final List<DateTime> dateTimes = [];

    final measurementUtcTimes = List<String>.from(measurementUtcTimesJson);

    for (final utcTime in measurementUtcTimes) {
      dateTimes.add(DateTime.parse(utcTime).toLocal());
    }

    return dateTimes;
  }

  @override
  List<DateTime> toJson(List<DateTime> dateTimes) {
    return [];
  }
}
