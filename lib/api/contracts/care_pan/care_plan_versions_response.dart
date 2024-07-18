import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_version_contract.dart';

part 'care_plan_versions_response.g.dart';

@JsonSerializable()
class CarePlanVersionsContract {
  final int count;
  final List<CarePlanVersionContract> items;

  CarePlanVersionsContract(this.count, this.items);

  factory CarePlanVersionsContract.fromJson(Map<String, dynamic> json) =>
      _$CarePlanVersionsContractFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanVersionsContractToJson(this);

  @override
  String toString() => toJson().toString();
}


// TODO: PagedList?