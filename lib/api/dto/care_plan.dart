import 'package:freezed_annotation/freezed_annotation.dart';

part 'care_plan.freezed.dart';
part 'care_plan.g.dart';

@freezed
class CarePlan with _$CarePlan {
  const CarePlan._();

  factory CarePlan(
    int id,
    String? targetUserMuid,
    String? finishedByUserMuid,
    CarePlanActivity activity,
    int versionId,
    String? authorUserMuid,
    DateTime scheduledStart,
    DateTime? scheduledEnd,
    int? frequency,
    int? period,
    TimeUnitEnumContract periodUnit,
    List<WeekDayEnumAppContract>? weekDays,
    List<TimingDayWhen> timingDayWhen,
  ) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);

  @override
  String toString() => toJson().toString();
}

@freezed
class CarePlanActivity with _$CarePlanActivity {
  factory CarePlanActivity(
    ActivityType activityType,
    MeasurementType measurementType,
    int? goalValue,
  ) = _CarePlanActivityAppContract;

  factory CarePlanActivity.fromJson(Map<String, dynamic> json) =>
      _$CarePlanActivityFromJson(json);

  @override
  String toString() => toJson().toString();
}

@freezed
class TimingDayWhen with _$TimingDayWhen {
  factory TimingDayWhen(
    TimingDayWhenType type,
    @TimeOfDayConverter() TimeOfDay start,
    @TimeOfDayConverter() TimeOfDay end,
    @TimeOfDayConverter() TimeOfDay? timeOfDay,
    WhenCode whenCode,
  ) = _TimingWhenDay;

  factory TimingDayWhen.fromJson(Map<String, dynamic> json) =>
      _$TimingDayWhenFromJson(json);

  @override
  String toString() => toJson().toString();
}

class TimeOfDay {
  int hour;
  int minute;
  int second;

  TimeOfDay(this.hour, this.minute, this.second);

  TimeOfDay.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute,
        second = dateTime.second;
}

class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String timeOfDayString) =>
      TimeOfDay.fromDateTime(DateTime.parse('2018-10-20 ${timeOfDayString}Z'));

  @override
  String toJson(TimeOfDay tod) => '${tod.hour}:${tod.minute}:${tod.second}';
}

enum ActivityType {
  @JsonValue('Measurement')
  measurement,
  @JsonValue('Goal')
  goal,
}

enum MeasurementType {
  @JsonValue('Temperature')
  temperature,
  @JsonValue('BloodPressure')
  bloodPressure,
  @JsonValue('OxygenSaturation')
  oxygenSaturation,
  @JsonValue('Steps')
  steps,
  @JsonValue('GlobalPosition')
  globalPosition,
  @JsonValue('HeartRate')
  heartRate,
  @JsonValue('Ews')
  ews,
  @JsonValue('RespiratoryRate')
  respiratoryRate,
}

enum TimingDayWhenType {
  @JsonValue('TimeOfDay')
  timeOfDay,
  @JsonValue('When')
  when
}

enum WhenCode {
  morning,
  @JsonValue('early-morning')
  earlyMorning,
  @JsonValue('late-morning')
  lateMorning,
  noon,
  afternoon,
  @JsonValue('early-afternoon')
  earlyAfternoon,
  @JsonValue('late-afternoon')
  lateAfternoon,
  evening,
  @JsonValue('early-evening')
  earlyEvening,
  @JsonValue('late-evening')
  lateEvening,
  night,
  @JsonValue('after-sleep')
  afterSleep,
  @JsonValue('before-sleep')
  beforeSleep,
  @JsonValue('after-waking')
  afterWaking,
  @JsonValue('at-breakfast')
  atBreakfast,
  @JsonValue('at-lunch')
  atLunch,
  @JsonValue('at-dinner')
  atDinner,
  @JsonValue('before-breakfast')
  beforeBreakfast,
  @JsonValue('before-lunch')
  beforeLunch,
  @JsonValue('before-dinner')
  beforeDinner,
  @JsonValue('before-breakfast')
  afterBreakfast,
  @JsonValue('after-lunch')
  afterLunch,
  @JsonValue('after-dinner')
  afterDinner,
}

enum TimeUnitEnumContract {
  hour,
  day,
  week,
  month,
  year,
}

enum WeekDayEnumAppContract {
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
