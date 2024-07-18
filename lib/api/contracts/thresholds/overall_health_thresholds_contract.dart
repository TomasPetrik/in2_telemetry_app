import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';

part 'overall_health_thresholds_contract.g.dart';

@JsonSerializable()
class OverallHealthThresholdsContract {
  final OverallHealthContract? max;

  OverallHealthThresholdsContract(this.max);

  factory OverallHealthThresholdsContract.fromJson(Map<String, dynamic> json) =>
      _$OverallHealthThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$OverallHealthThresholdsContractToJson(this);

  @override
  String toString() => toJson().toString();
}
