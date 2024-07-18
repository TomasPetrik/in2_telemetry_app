import 'package:json_annotation/json_annotation.dart';

part 'heart_rate_thresholds_contract.g.dart';

@JsonSerializable()
class HeartRateThresholdsContract {
  final int? min;
  final int? max;

  const HeartRateThresholdsContract({
    this.min,
    this.max,
  });

  factory HeartRateThresholdsContract.fromJson(Map<String, dynamic> json) => _$HeartRateThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateThresholdsContractToJson(this);

  @override
  String toString() => toJson().toString();
}