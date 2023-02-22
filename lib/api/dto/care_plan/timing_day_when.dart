import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'timing_day_when.freezed.dart';
part 'timing_day_when.g.dart';

@freezed
class TimingDayWhen with _$TimingDayWhen {
  TimingDayWhen._();

  @HiveType(typeId: 17, adapterName: 'TimingDayWhenAdapter')
  factory TimingDayWhen(
    @HiveField(0) TimingDayWhenType type,
    @HiveField(1) @TimeOfDayConverter() TimeOfDay start,
    @HiveField(2) @TimeOfDayConverter() TimeOfDay end,
    @HiveField(3) @TimeOfDayConverter() TimeOfDay? timeOfDay,
    @HiveField(4) WhenCode? whenCode,
  ) = _TimingWhenDay;

  factory TimingDayWhen.fromJson(Map<String, dynamic> json) =>
      _$TimingDayWhenFromJson(json);

  @override
  String toString() => toJson().toString();

  bool isInInterval(TimeOfDay exactTime) {
    if (exactTime.isBefore(end) && exactTime.isAfter(start)) {
      return true;
    } else {
      return false;
    }
  }
}

@HiveType(typeId: 18)
class TimeOfDay extends HiveObject {
  @HiveField(0)
  int hour;
  @HiveField(1)
  int minute;
  @HiveField(2)
  int second;

  TimeOfDay(this.hour, this.minute, this.second);

  TimeOfDay.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute,
        second = dateTime.second;

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  bool isBefore(TimeOfDay exactTime) {
    final todayDayTime = todayDateTime();
    final cmpTime = exactTime.todayDateTime();
    return todayDayTime.isBefore(cmpTime);
  }

  bool isAfter(TimeOfDay exactTime) {
    final todayDayTime = todayDateTime();
    final cmpTime = exactTime.todayDateTime();
    return todayDayTime.isAfter(cmpTime);
  }

  DateTime ofExactDate(DateTime dateTime) {
    return dateTime.copyWith(
      hour: hour,
      minute: minute,
      second: second,
      millisecond: 0,
      microsecond: 0,
    );
  }

  DateTime todayDateTime() {
    return DateTime.now().copyWith(
      hour: hour,
      minute: minute,
      second: second,
      millisecond: 0,
      microsecond: 0,
    );
  }

  DateTime tomorrowDateTime() {
    final today = DateTime.now();
    return today.copyWith(
      day: today.day + 1,
      hour: hour,
      minute: minute,
      second: second,
    );
  }

  DateTime yesterdayDateTime() {
    final today = DateTime.now();
    return today.copyWith(
      day: today.day - 1,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: 0,
      microsecond: 0,
    );
  }
}

class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String timeOfDayString) =>
      TimeOfDay.fromDateTime(DateTime.parse('2018-10-20 ${timeOfDayString}Z'));

  @override
  String toJson(TimeOfDay tod) => '${tod.hour}:${tod.minute}:${tod.second}';
}

@HiveType(typeId: 19)
enum TimingDayWhenType {
  @JsonValue('TimeOfDay')
  @HiveField(0)
  timeOfDay,
  @JsonValue('When')
  @HiveField(1)
  when;
}

@HiveType(typeId: 20)
enum WhenCode {
  @HiveField(0)
  morning,
  @JsonValue('early-morning')
  @HiveField(1)
  earlyMorning,
  @JsonValue('late-morning')
  @HiveField(2)
  lateMorning,
  @HiveField(3)
  noon,
  @HiveField(4)
  afternoon,
  @JsonValue('early-afternoon')
  @HiveField(5)
  earlyAfternoon,
  @JsonValue('late-afternoon')
  @HiveField(6)
  lateAfternoon,
  @HiveField(7)
  evening,
  @JsonValue('early-evening')
  @HiveField(8)
  earlyEvening,
  @JsonValue('late-evening')
  @HiveField(9)
  lateEvening,
  @HiveField(10)
  night,
  @JsonValue('after-sleep')
  @HiveField(11)
  afterSleep,
  @JsonValue('before-sleep')
  @HiveField(12)
  beforeSleep,
  @JsonValue('after-waking')
  @HiveField(13)
  afterWaking,
  @JsonValue('at-breakfast')
  @HiveField(14)
  atBreakfast,
  @JsonValue('at-lunch')
  @HiveField(15)
  atLunch,
  @JsonValue('at-dinner')
  @HiveField(16)
  atDinner,
  @JsonValue('before-breakfast')
  @HiveField(17)
  beforeBreakfast,
  @JsonValue('before-lunch')
  @HiveField(18)
  beforeLunch,
  @JsonValue('before-dinner')
  @HiveField(19)
  beforeDinner,
  @JsonValue('after-breakfast')
  @HiveField(20)
  afterBreakfast,
  @JsonValue('after-lunch')
  @HiveField(21)
  afterLunch,
  @JsonValue('after-dinner')
  @HiveField(22)
  afterDinner;
}
