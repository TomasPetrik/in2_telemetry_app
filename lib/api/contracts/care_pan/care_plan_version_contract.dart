import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_day_when_contract.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'care_plan_version_contract.g.dart';

@JsonSerializable()
class CarePlanVersionContract {
  final int versionId;
  final String? authorUserMuid;

  @JsonKey(fromJson: toLocalDate)
  final DateTime scheduledStart;

  @JsonKey(fromJson: toLocalDateNullable)
  final DateTime? scheduledEnd;

  final int frequency;
  final int period;
  final TimeUnitContract periodUnit;
  final List<WeekDayContract> weekDays;
  final List<TimingDayWhenContract> timingDayWhen;

  @JsonKey(fromJson: toLocalDate)
  final DateTime activeFrom;

  @JsonKey(fromJson: toLocalDateNullable)
  final DateTime? activeTo;

  CarePlanVersionContract({
    required this.versionId,
    this.authorUserMuid,
    required this.scheduledStart,
    this.scheduledEnd,
    required this.frequency,
    required this.period,
    required this.periodUnit,
    required this.weekDays,
    required this.timingDayWhen,
    required this.activeFrom,
    this.activeTo,
  });

  factory CarePlanVersionContract.fromJson(Map<String, dynamic> json) => _$CarePlanVersionContractFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanVersionContractToJson(this);
}
