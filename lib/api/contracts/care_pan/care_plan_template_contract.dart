import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/time_settings/when_setting_contract.dart';

part 'care_plan_template_contract.g.dart';

@JsonSerializable()
class CarePlanTemplateContract {
  final List<WhenSettingContract> whenTimeValues;
  final int timeToleranceMinutes;

  CarePlanTemplateContract(this.whenTimeValues, this.timeToleranceMinutes);

  factory CarePlanTemplateContract.fromJson(Map<String, dynamic> json) =>
      _$CarePlanTemplateContractFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanTemplateContractToJson(this);

  @override
  String toString() => toJson().toString();
}