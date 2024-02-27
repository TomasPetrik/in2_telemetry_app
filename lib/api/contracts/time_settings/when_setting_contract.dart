import 'package:json_annotation/json_annotation.dart';

part 'when_setting_contract.g.dart';

@JsonSerializable()
class WhenSettingContract {
  final String codeValue;
  final String start;
  final String end;
  final String? userEditMin;
  final String? userEditMax;

  const WhenSettingContract({
    required this.codeValue,
    required this.start,
    required this.end,
    this.userEditMin,
    this.userEditMax,
  });

  factory WhenSettingContract.fromJson(Map<String, dynamic> json) => _$WhenSettingContractFromJson(json);

  Map<String, dynamic> toJson() => _$WhenSettingContractToJson(this);

  @override
  String toString() => toJson().toString();
}
