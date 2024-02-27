import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/time_settings/when_code_contract.dart';

part 'time_setting_contract.g.dart';

@JsonSerializable()
class TimeSettingContract {
  final int? id;
  final WhenCodeContract code;
  final String start;
  final String end;
  final String? userMuid;

  TimeSettingContract({
    this.id,
    required this.code,
    required this.start,
    required this.end,
    this.userMuid,
  });

  factory TimeSettingContract.fromJson(Map<String, dynamic> json) =>
      _$TimeSettingContractFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSettingContractToJson(this);

  @override
  String toString() => toJson().toString();
}