import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blood_pressure_value.g.dart';

@JsonSerializable()
class BloodPressureValue {
  int? systolic;
  int? diastolic;

  BloodPressureValue({
    required this.systolic,
    required this.diastolic,
  });

  factory BloodPressureValue.fromJson(Map<String, dynamic> json) => _$BloodPressureValueFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureValueToJson(this);

  static TypeConverter<BloodPressureValue, String> converter = TypeConverter.json(
    fromJson: (json) => BloodPressureValue.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );
}
