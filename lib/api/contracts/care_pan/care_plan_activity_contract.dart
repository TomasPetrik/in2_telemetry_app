import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/activity_type_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';

part 'care_plan_activity_contract.g.dart';

@JsonSerializable()
class CarePlanActivityContract {
  final ActivityTypeContract activityType;
  final MeasurementTypeContract measurementType;
  final int? goalValue;

  CarePlanActivityContract({
    required this.activityType,
    required this.measurementType,
    this.goalValue,
  });

  factory CarePlanActivityContract.fromJson(Map<String, dynamic> json) =>
      _$CarePlanActivityContractFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanActivityContractToJson(this);

  @override
  String toString() => toJson().toString();
}