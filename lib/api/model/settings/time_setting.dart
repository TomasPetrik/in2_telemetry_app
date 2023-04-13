import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';

part 'time_setting.freezed.dart';
part 'time_setting.g.dart';

@unfreezed
class TimeSetting with _$TimeSetting {
  TimeSetting._();

  @HiveType(typeId: 26, adapterName: 'TimeSettingAdapter')
  factory TimeSetting({
    @HiveField(0) int? id,
    @HiveField(1) required WhenCode code,
    @HiveField(2) @TimeOfDayConverter() required DailyTime start,
    @HiveField(3) @TimeOfDayConverter() required DailyTime end,
    @HiveField(4) String? userMuid,
  }) = _TimeSetting;

  factory TimeSetting.fromJson(Map<String, dynamic> json) =>
      _$TimeSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
