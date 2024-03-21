import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/week_day.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/data/entities/enums/time_unit.dart';

part 'care_plan_version.g.dart';

@JsonSerializable()
class CarePlanVersion {
  int versionId;
  DateTime scheduledStart;
  DateTime? scheduledEnd;
  int frequency;
  int period;
  TimeUnit periodUnit;
  List<WeekDay> weekDays;
  List<TimingDayWhen> timingDayWhen;
  DateTime activeFrom;
  DateTime? activeTo;

  CarePlanVersion(
    this.versionId,
    this.scheduledStart,
    this.frequency,
    this.period,
    this.periodUnit,
    this.weekDays,
    this.timingDayWhen,
    this.activeFrom, {
    this.scheduledEnd,
    this.activeTo,
  });

  factory CarePlanVersion.fromJson(Map<String, dynamic> json) => _$CarePlanVersionFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanVersionToJson(this);

  static TypeConverter<List<CarePlanVersion>, String> listConverter = TypeConverter.json(
    fromJson: (fromJson) => jsonDecode(fromJson).cast<Map<String,dynamic>>().map<CarePlanVersion>(CarePlanVersion.fromJson).toList(),
    toJson: (obj) => json.encode(obj),
  );
}
