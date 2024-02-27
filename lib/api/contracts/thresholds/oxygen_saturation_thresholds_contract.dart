import 'package:json_annotation/json_annotation.dart';

part 'oxygen_saturation_thresholds_contract.g.dart';

@JsonSerializable()
class OxygenSaturationThresholdsContract {
  final double? percentageMin;
  final double? percentageMax;

  OxygenSaturationThresholdsContract({this.percentageMin, this.percentageMax});

  factory OxygenSaturationThresholdsContract.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$OxygenSaturationThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$OxygenSaturationThresholdsContractToJson(this);

  @override
  String toString() => toJson().toString();
}
