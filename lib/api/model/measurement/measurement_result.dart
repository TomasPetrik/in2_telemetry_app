import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'measurement_result.freezed.dart';
part 'measurement_result.g.dart';
part 'measurement_result.hive.dart';

@unfreezed
class MeasurementResult with _$MeasurementResult {
  MeasurementResult._();

  @HiveType(typeId: 30, adapterName: 'MeasurementResultAdapter')
  factory MeasurementResult({
    @JsonKey(fromJson: toLocalDate)
    @HiveField(0)
        required DateTime measurementDateTime,
    @HiveField(1) double? value,
    @HiveField(2) ComposedDoubleValue? composedValue,
    @HiveField(3) Device? sourceDevice,
    @HiveField(4) bool? isVerified,
    @JsonKey(name: 'type') @HiveField(5) MeasurementTypeContract? measurementType,
    @JsonKey(includeToJson: false) @HiveField(6) WhenCode? whenCode,
    @JsonKey(includeToJson: false)
    @HiveField(7)
        FulfillmentEvaluationItem? evaluationItem,
    @JsonKey(includeToJson: false)
    @HiveField(8)
        DateTime? measurementIntervalEnd,
    @JsonKey(includeToJson: false) @HiveField(9) String? userId,
    @JsonKey(includeToJson: false) @HiveField(10) int? reqCount,
    @JsonKey(includeToJson: false) @HiveField(11) int? currentCount,
    @JsonKey(includeToJson: false)
    @HiveField(12)
        DateTime? measurementIntervalStart,
  }) = _MeasurementResult;

  factory MeasurementResult.fromJson(Map<String, dynamic> json) =>
      _$MeasurementResultFromJson(json);

  @override
  String toString() => toJson().toString();

  bool get isLongPeriod =>
      reqCount != null &&
      reqCount! > 1 &&
      measurementIntervalStart!
              .difference(measurementIntervalEnd!)
              .abs()
              .inHours >
          23;

  bool get wasMeasured =>
      currentCount != null && reqCount != null && (currentCount! >= reqCount!);
}

@freezed
class MeasurementResults with _$MeasurementResults {
  MeasurementResults._();

  @HiveType(typeId: 40, adapterName: 'MeasurementResultsAdapter')
  factory MeasurementResults({
    @HiveField(0) required List<MeasurementResult> items,
  }) = _MeasurementResults;
}
