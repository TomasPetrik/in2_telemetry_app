import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';

part 'time_settings_update_contract.g.dart';

@JsonSerializable()
class TimeSettingsUpdateContract {
  final List<TimeSettingContract> settings;
  final String userMuid;

  TimeSettingsUpdateContract(this.settings, this.userMuid);

  factory TimeSettingsUpdateContract.fromJson(Map<String, dynamic> json) =>
      _$TimeSettingsUpdateContractFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSettingsUpdateContractToJson(this);

  @override
  String toString() => toJson().toString();
}