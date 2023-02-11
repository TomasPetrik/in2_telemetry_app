import 'package:scalesoft_app/model/measurement_info.dart';

class HwMeasurementResult {
  final MeasurementInfo? measurementInfo;
  final ResultState resultState;

  HwMeasurementResult({required this.resultState, this.measurementInfo});
}

enum ResultState { success, noData, connectionError }
