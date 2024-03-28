import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';

class MeasurementResultViewModel {
  final DateTime measurementTime;
  final MeasurementType measurementType;
  final int requiredCount;
  final int actualCount;
  String? result;
  final UserModel user;
  final DateTime? measurementIntervalStart;
  final DateTime? measurementIntervalEnd;
  final WhenCode? whenCode;

  MeasurementResultViewModel(
    this.measurementType,
    this.measurementTime,
    this.user,
    this.requiredCount,
    this.actualCount,
    this.whenCode, {
    this.result,
    this.measurementIntervalStart,
    this.measurementIntervalEnd,
  });

  bool get spansMultipleDays =>
      measurementIntervalStart != null &&
      measurementIntervalEnd != null &&
      measurementIntervalStart != measurementIntervalEnd;
}
