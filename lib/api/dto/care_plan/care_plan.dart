import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/care_plan/author.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';

part 'care_plan.freezed.dart';
part 'care_plan.g.dart';

@unfreezed
class CarePlan with _$CarePlan {
  @HiveType(typeId: 10, adapterName: 'CarePlanAdapter')
  factory CarePlan(
    @HiveField(0) int id,
    @HiveField(1) String? targetUserMuid,
    @HiveField(2) String? finishedByUserMuid,
    @HiveField(3) CarePlanActivity activity,
    @HiveField(4) int versionId,
    @HiveField(5) Author author,
    @HiveField(6) DateTime scheduledStart,
    @HiveField(7) DateTime? scheduledEnd,
    @HiveField(8) int frequency,
    @HiveField(9) int period,
    @HiveField(10) TimeUnitEnumContract periodUnit,
    @HiveField(11) List<WeekDayEnumAppContract>? weekDays,
    @HiveField(12) List<TimingDayWhen> timingDayWhen,
    @HiveField(13) FulfillmentEvaluation? fulfillmentEvaluation,
  ) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 15)
enum TimeUnitEnumContract {
  @JsonValue('hour')
  @HiveField(0)
  hour,
  @JsonValue('day')
  @HiveField(1)
  day,
  @JsonValue('week')
  @HiveField(2)
  week,
  @JsonValue('month')
  @HiveField(3)
  month,
  @JsonValue('year')
  @HiveField(4)
  year;
}

@HiveType(typeId: 16)
enum WeekDayEnumAppContract {
  @JsonValue('Monday')
  @HiveField(0)
  monday,
  @JsonValue('Tuesday')
  @HiveField(1)
  tuesday,
  @JsonValue('Wednesday')
  @HiveField(2)
  wednesday,
  @JsonValue('Thursday')
  @HiveField(3)
  thursday,
  @JsonValue('Friday')
  @HiveField(4)
  friday,
  @JsonValue('Saturday')
  @HiveField(5)
  saturday,
  @JsonValue('Sunday')
  @HiveField(6)
  sunday;
}
