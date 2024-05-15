import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

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

  /// Shall be set to `true` when the measurement was part of a care plan,
  /// `false` when the measurement was unplanned.
  final bool wasPlanned;

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
    this.wasPlanned = false,
  });

  bool get spansMultipleDays =>
      measurementIntervalStart != null &&
      measurementIntervalEnd != null &&
      !measurementIntervalStart!.isSameDate(measurementIntervalEnd!) &&
      actualCount < requiredCount;
}
