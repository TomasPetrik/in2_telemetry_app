import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/when_time_value.dart';

part 'template_time_set.freezed.dart';
part 'template_time_set.g.dart';
part 'template_time_set.hive.dart';

@freezed
class TemplateTimeSet with _$TemplateTimeSet {
  const TemplateTimeSet._();

  @HiveType(typeId: 24, adapterName: 'TemplateTimeSetAdapter')
  const factory TemplateTimeSet(
    @HiveField(0) List<WhenTimeValue> whenTimeValues,
    @HiveField(1) int timeToleranceMinutes,
  ) = _TemplateTimeSet;

  factory TemplateTimeSet.fromJson(Map<String, dynamic> json) =>
      _$TemplateTimeSetFromJson(json);

  @override
  String toString() => toJson().toString();
}
