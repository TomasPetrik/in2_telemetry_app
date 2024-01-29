import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/daily_timing_model.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/timing_model.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/when_model.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'care_plan_version.freezed.dart';

part 'care_plan_version.g.dart';

@freezed
class CarePlanVersion with _$CarePlanVersion {
  CarePlanVersion._();

  // TODO: Move care plan details here and possibly store only versions?

  @HiveType(typeId: 27, adapterName: 'CarePlanVersionAdapter')
  factory CarePlanVersion({
    @HiveField(0) required int versionId,
    @HiveField(1) String? authorUserMuid,
    @JsonKey(fromJson: toLocalDate)
    @HiveField(2)
    required DateTime scheduledStart,
    @JsonKey(fromJson: toLocalDateNullable)
    @HiveField(3)
    DateTime? scheduledEnd,
    @HiveField(4) required int frequency,
    @HiveField(5) required int period,
    @HiveField(6) required TimeUnit periodUnit,
    @HiveField(7) required List<WeekDay> weekDays,
    @HiveField(8) required List<TimingDayWhen> timingDayWhen,
    @JsonKey(fromJson: toLocalDate) @HiveField(9) required DateTime activeFrom,
    @JsonKey(fromJson: toLocalDateNullable)
    @HiveField(10)
    required DateTime? activeTo,
  }) = _CarePlanVersion;

  factory CarePlanVersion.fromJson(Map<String, dynamic> json) =>
      _$CarePlanVersionFromJson(json);

  bool get isPeriodical => timingDayWhen.isEmpty;

  bool isActiveInDates(DateTime from, DateTime to) {
    if (activeFrom.isBefore(to) &&
        (activeTo == null || activeTo!.isAfter(from))) {
      return true;
    } else {
      return false;
    }
  }

  List<WhenModel> get when {
    return timingDayWhen
        .where(
          (x) => x.type == TimingDayWhenType.when && x.whenCode != null,
        )
        .map(
          (x) => WhenModel(whenCode: x.whenCode!, start: x.start, end: x.end),
        )
        .toList();
  }

  List<TimeOfDayTimingModel> get timesOfDay {
    return timingDayWhen
        .where(
          (x) => x.type == TimingDayWhenType.timeOfDay && x.timeOfDay != null,
        )
        .map(
          (x) => TimeOfDayTimingModel(
            measurementWindowStart: x.start.toDuration(),
            measurementWindowEnd: x.end.toDuration(),
          ),
        )
        .toList();
  }

  TimingModel get timing {
    return TimingModel(
      frequency,
      period,
      periodUnit,
      weekDays,
      timesOfDay,
      when,
    );
  }
}
