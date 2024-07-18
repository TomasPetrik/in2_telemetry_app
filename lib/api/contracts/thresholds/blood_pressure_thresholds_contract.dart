import 'package:json_annotation/json_annotation.dart';

part 'blood_pressure_thresholds_contract.g.dart';

@JsonSerializable()
class BloodPressureThresholdsContract {
  final int? systolicMin;
  final int? systolicMax;
  final int? diastolicMin;
  final int? diastolicMax;

  BloodPressureThresholdsContract({
    this.systolicMin,
    this.systolicMax,
    this.diastolicMin,
    this.diastolicMax,
  });

  factory BloodPressureThresholdsContract.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureThresholdsContractToJson(this);

  @override
  String toString() => toJson().toString();
}
