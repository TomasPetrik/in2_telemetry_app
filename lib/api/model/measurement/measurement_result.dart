import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/overall_health_value.dart';
import 'package:scalesoft_app/api/model/measurement/shortness_of_breath_value.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
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
    @JsonKey(name: 'type') @HiveField(5) MeasurementType? measurementType,
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

  // TODO: Deduplicate this and the same method in measurement.dart
  // Ideally change the API and replace MeasurementResult with Measurement
  String getFormattedValue() {
    if (measurementType == null) {
      return "";
    }

    final stringValue = switch (measurementType!) {
      MeasurementType.temperature => value?.toStringAsFixed(1),
      MeasurementType.bloodPressure =>
        "${composedValue?.firstValue?.toStringAsFixed(0) ?? '?'}/${composedValue?.secondValue?.toStringAsFixed(0) ?? '?'}",
      MeasurementType.oxygenSaturation ||
      MeasurementType.heartRate ||
      MeasurementType.respiratoryRate ||
      MeasurementType.ews =>
        value?.toInt().toString(),
      MeasurementType.shortnessOfBreath => value != null
          ? localization.shortness_of_breath_values(
              ShortnessOfBreathValue.values
                  .firstWhere((x) => x.value == value!.toInt()),
            )
          : "",
      MeasurementType.overallHealth => value != null
          ? localization.overall_health_values(
              OverallHealthValue.values
                  .firstWhere((x) => x.value == value!.toInt()),
            )
          : "",
      MeasurementType.steps ||
      MeasurementType.globalPosition =>
        "",
    };

    return "$stringValue ${localization.common_measurement_units_types(measurementType!)}";
  }
}

@freezed
class MeasurementResults with _$MeasurementResults {
  MeasurementResults._();

  @HiveType(typeId: 40, adapterName: 'MeasurementResultsAdapter')
  factory MeasurementResults({
    @HiveField(0) required List<MeasurementResult> items,
  }) = _MeasurementResults;
}
