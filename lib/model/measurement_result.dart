import 'package:scalesoft_app/model/measurement_info.dart';

class MeasurementResult {
  final MeasurementInfo? measurementInfo;
  final ResultState resultState;

  MeasurementResult({required this.resultState, this.measurementInfo});
}

enum ResultState { success, noData, connectionError }
