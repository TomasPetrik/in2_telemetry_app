import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'care_plan_version.freezed.dart';
part 'care_plan_version.g.dart';
part 'care_plan_version.hive.dart';

@freezed
class CarePlanVersion with _$CarePlanVersion {
  CarePlanVersion._();

  @HiveType(typeId: 27, adapterName: 'CarePlanVersionAdapter')
  factory CarePlanVersion({
    @HiveField(0)
        required int versionId,
    @HiveField(1)
        String? authorUserMuid,
    @JsonKey(fromJson: toLocalDate)
    @HiveField(2)
        required DateTime scheduledStart,
    @JsonKey(fromJson: toLocalDateNullable)
    @HiveField(3)
        DateTime? scheduledEnd,
    @HiveField(4)
        required int frequency,
    @HiveField(5)
        required int period,
    @HiveField(6)
        required TimeUnit periodUnit,
    @HiveField(7)
        required List<WeekDay> weekDays,
    @HiveField(8)
        required List<TimingDayWhen> timingDayWhen,
    @JsonKey(fromJson: toLocalDate)
    @HiveField(9)
        required DateTime activeFrom,
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
}
