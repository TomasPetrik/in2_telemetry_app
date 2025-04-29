import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';

part 'hw_measurement_result.freezed.dart';

@freezed
class HwMeasurementResult with _$HwMeasurementResult {
  const factory HwMeasurementResult({
    required ResultState resultState,
    required DateTime measurementDt,
    MeasurementCreateModel? measurement,
  }) = _HwMeasurementResult;
}

enum ResultState { success, noData, connectionError }
