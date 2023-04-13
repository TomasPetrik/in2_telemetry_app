import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';

part 'care_plan_changes.freezed.dart';
part 'care_plan_changes.g.dart';

@freezed
class CarePlanChanges with _$CarePlanChanges {
  const CarePlanChanges._();

  factory CarePlanChanges(
    List<CarePlan>? newOrUpdatedPlans,
    List<int>? expiredPlanIds,
  ) = _CarePlanChanges;

  factory CarePlanChanges.fromJson(Map<String, dynamic> json) =>
      _$CarePlanChangesFromJson(json);

  @override
  String toString() => toJson().toString();
}
