import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';

part 'active_care_plans_contract.g.dart';

@JsonSerializable()
class ActiveCarePlansContract {
  final int count;
  final List<CarePlanContract> items;

  ActiveCarePlansContract(this.count, this.items);

  factory ActiveCarePlansContract.fromJson(Map<String, dynamic> json) => _$ActiveCarePlansContractFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveCarePlansContractToJson(this);

  @override
  String toString() => toJson().toString();
}
