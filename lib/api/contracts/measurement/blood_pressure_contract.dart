import 'package:json_annotation/json_annotation.dart';

part 'blood_pressure_contract.g.dart';

@JsonSerializable(explicitToJson: true)
class BloodPressureContract {
  final int systolic;
  final int diastolic;

  const BloodPressureContract({required this.systolic, required this.diastolic});

  factory BloodPressureContract.fromJson(Map<String, dynamic> json) => _$BloodPressureContractFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureContractToJson(this);

  @override
  String toString() => toJson().toString();
}
