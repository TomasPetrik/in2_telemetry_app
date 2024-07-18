import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blood_pressure_thresholds.g.dart';

@JsonSerializable()
class BloodPressureThresholds {
  int? systolicMin;
  int? systolicMax;
  int? diastolicMin;
  int? diastolicMax;

  BloodPressureThresholds(this.systolicMin, this.systolicMax, this.diastolicMin, this.diastolicMax);

  factory BloodPressureThresholds.fromJson(Map<String, dynamic> json) => _$BloodPressureThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureThresholdsToJson(this);

  static TypeConverter<BloodPressureThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => BloodPressureThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  bool exceeds(int? systolic, int? diastolic) {
    if (systolic != null) {
      if (systolicMin != null && systolic < systolicMin!) {
        return true;
      }
      if (systolicMax != null && systolic > systolicMax!) {
        return true;
      }
    }
    if (diastolic != null) {
      if (diastolicMin != null && diastolic < diastolicMin!) {
        return true;
      }
      if (diastolicMax != null && diastolic > diastolicMax!) {
        return true;
      }
    }
    return false;
  }
}
