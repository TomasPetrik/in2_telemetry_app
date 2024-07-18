import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shortness_of_breath_thresholds_contract.g.dart';

@JsonSerializable(explicitToJson: true)
class ShortnessOfBreathThresholdsContract {
  final ShortnessOfBreathContract? max;

  ShortnessOfBreathThresholdsContract({this.max});

  factory ShortnessOfBreathThresholdsContract.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ShortnessOfBreathThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$ShortnessOfBreathThresholdsContractToJson(this);

  @override
  String toString() => toJson().toString();
}
