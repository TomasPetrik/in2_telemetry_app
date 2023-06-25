import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/model/measurement_info.dart';

part 'hw_measurement_result.freezed.dart';

@freezed
class HwMeasurementResult with _$HwMeasurementResult {
  const factory HwMeasurementResult({
    required ResultState resultState,
    required DateTime measurementDt,
    MeasurementInfo? measurementInfo,
    Measurement? measurement,
  }) = _HwMeasurementResult;
}

enum ResultState { success, noData, connectionError }
