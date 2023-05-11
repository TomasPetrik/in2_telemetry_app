import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';

part 'when_time_value.freezed.dart';
part 'when_time_value.g.dart';
part 'when_time_value.hive.dart';

@freezed
class WhenTimeValue with _$WhenTimeValue {
  WhenTimeValue._();

  @HiveType(typeId: 25, adapterName: 'WhenTimeValueAdapter')
  factory WhenTimeValue(
    @HiveField(0) WhenCode codeValue,
    @HiveField(1) bool isUserEditableAndApplyUserValueOnPlan,
    @HiveField(2) @TimeOfDayConverter() DailyTime start,
    @HiveField(3) @TimeOfDayConverter() DailyTime end,
    @HiveField(4) @TimeOfDayConverter() DailyTime? userEditMin,
    @HiveField(5) @TimeOfDayConverter() DailyTime? userEditMax,
  ) = _WhenTimeValue;

  factory WhenTimeValue.fromJson(Map<String, dynamic> json) =>
      _$WhenTimeValueFromJson(json);

  @override
  String toString() => toJson().toString();
}
