import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/author_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_day_when_contract.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'care_plan_contract.g.dart';

@JsonSerializable()
class CarePlanContract {
  final int id;
  final String targetUserMuid;
  final String? finishedByUserMuid;
  final CarePlanActivityContract activity;
  final int versionId;
  final AuthorContract author;
  @JsonKey(fromJson: toLocalDate)
  final DateTime scheduledStart;
  @JsonKey(fromJson: toLocalDateNullable)
  final DateTime? scheduledEnd;
  final int? frequency;
  final int? period;
  final TimeUnitContract? periodUnit;
  final List<WeekDayContract> weekDays;
  final List<TimingDayWhenContract> timingDayWhen;

  CarePlanContract({
    required this.id,
    required this.targetUserMuid,
    this.finishedByUserMuid,
    required this.activity,
    required this.versionId,
    required this.author,
    required this.scheduledStart,
    this.scheduledEnd,
    this.frequency,
    this.period,
    this.periodUnit,
    required this.weekDays,
    required this.timingDayWhen,
  });

  factory CarePlanContract.fromJson(Map<String, dynamic> json) =>
      _$CarePlanContractFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanContractToJson(this);

  @override
  String toString() => toJson().toString();
}

enum TimeUnitContract {
  @JsonValue('hour')
  hour,
  @JsonValue('day')
  day,
  @JsonValue('week')
  week,
  @JsonValue('month')
  month,
  @JsonValue('year')
  year,
}

enum WeekDayContract {
  @JsonValue('Monday')
  monday,
  @JsonValue('Tuesday')
  tuesday,
  @JsonValue('Wednesday')
  wednesday,
  @JsonValue('Thursday')
  thursday,
  @JsonValue('Friday')
  friday,
  @JsonValue('Saturday')
  saturday,
  @JsonValue('Sunday')
  sunday,
}
