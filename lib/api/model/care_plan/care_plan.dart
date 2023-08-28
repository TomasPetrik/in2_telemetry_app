import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/author.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/daily_timing_model.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/timing_model.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/when_model.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'care_plan.freezed.dart';
part 'care_plan.g.dart';
part 'care_plan.hive.dart';

@unfreezed
class CarePlan with _$CarePlan {
  CarePlan._();

  @HiveType(typeId: 10, adapterName: 'CarePlanAdapter')
  factory CarePlan({
    @HiveField(0) required int id,
    @HiveField(1) String? targetUserMuid,
    @HiveField(2) String? finishedByUserMuid,
    @HiveField(3) required CarePlanActivityContract activity,
    @HiveField(4) required int versionId,
    @HiveField(5) required Author author,
    @JsonKey(fromJson: toLocalDate)
    @HiveField(6)
    required DateTime scheduledStart,
    @JsonKey(fromJson: toLocalDateNullable)
    @HiveField(7)
    DateTime? scheduledEnd,
    @HiveField(8) required int frequency,
    @HiveField(9) required int period,
    @HiveField(10) required TimeUnit periodUnit,
    @HiveField(11) required List<WeekDay> weekDays,
    @HiveField(12) required List<TimingDayWhen> timingDayWhen,
    @HiveField(13) FulfillmentEvaluationAggregated? fullPlanEvaluation,
    @HiveField(14) List<FulfillmentEvaluationItem>? serverEvaluationItems,
    @HiveField(15) bool? wasChanged,
    @HiveField(16) String? userId,
    @HiveField(17) bool? wasExpired,
    @HiveField(18) List<CarePlanVersion>? carePlanVersions,
  }) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);

  @override
  String toString() => toJson().toString();

  bool get isPeriodical => timingDayWhen.isEmpty;

  bool get started => scheduledStart.isBefore(DateTime.now());

  bool get finished => scheduledEnd?.isBefore(DateTime.now()) == true;

  void addEvaluationItems(List<FulfillmentEvaluationItem> newEvItems) {
    final List<FulfillmentEvaluationItem> newEvItemsList =
        serverEvaluationItems != null ? [...serverEvaluationItems!] : [];

    for (final newEvItem in newEvItems) {
      if (newEvItemsList.none((evItem) => evItem.start == newEvItem.start) ==
          true) {
        newEvItemsList.add(newEvItem);
      }
    }
    serverEvaluationItems = newEvItemsList;
  }

  bool isActiveToday() {
    if (scheduledEnd == null) {
      return true;
    }

    final todayStart = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);

    return scheduledEnd!.isAfter(todayStart);
  }

  List<CarePlanVersion> getCpVersions() {
    final List<CarePlanVersion> sortedPlanVersions = [
      if (carePlanVersions != null) ...carePlanVersions!,
    ]..sort(
        (a, b) => a.activeFrom.compareTo(b.activeFrom),
      );

    final cpVersions = sortedPlanVersions.isNotEmpty
        ? sortedPlanVersions
        : [
            CarePlanVersion(
              versionId: versionId,
              scheduledStart: scheduledStart,
              frequency: frequency,
              period: period,
              periodUnit: periodUnit,
              weekDays: weekDays,
              timingDayWhen: timingDayWhen,
              activeFrom: scheduledStart,
              activeTo: scheduledEnd,
            ),
          ];

    return cpVersions;
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

@HiveType(typeId: 15)
enum TimeUnit {
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
enum WeekDay {
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
