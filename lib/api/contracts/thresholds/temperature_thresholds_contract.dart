import 'package:json_annotation/json_annotation.dart';

part 'temperature_thresholds_contract.g.dart';

@JsonSerializable()
class TemperatureThresholdsContract {
  final double? min;
  final double? max;

  const TemperatureThresholdsContract({this.min, this.max});

  factory TemperatureThresholdsContract.fromJson(Map<String, dynamic> json) =>
      _$TemperatureThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureThresholdsContractToJson(this);
}
