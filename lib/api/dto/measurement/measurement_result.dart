import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'measurement_result.freezed.dart';
part 'measurement_result.g.dart';

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
    @JsonKey(ignore: true) @HiveField(6) FulfillmentEvaluationItem? evaluationItem,
    @JsonKey(ignore: true) @HiveField(7) DateTime? measurementFinishDateTime,
    @JsonKey(ignore: true) @HiveField(8) String? userId,
  }) = _MeasurementResult;

  factory MeasurementResult.fromJson(Map<String, dynamic> json) =>
      _$MeasurementResultFromJson(json);

  @override
  String toString() => toJson().toString();
}
