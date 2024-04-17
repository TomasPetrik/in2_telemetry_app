import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time_only.g.dart';

@JsonSerializable(constructor: "fromTotalSeconds")
class TimeOnly {
  static const secondsInMinute = 60;
  static const secondsInHour = 60 * secondsInMinute;

  final int totalSeconds;

  int get hour => totalSeconds ~/ secondsInHour;

  int get minute => (totalSeconds % secondsInHour) ~/ secondsInMinute;

  int get second => totalSeconds % secondsInMinute;

  TimeOnly(int hours, int minutes, int seconds)
      : totalSeconds = hours * secondsInHour + minutes * secondsInMinute + seconds;

  TimeOnly.fromTotalSeconds(this.totalSeconds);

  TimeOnly.fromDateTime(DateTime dateTime) : this(dateTime.hour, dateTime.minute, dateTime.second);

  TimeOnly.fromString(String timeOfDayString) : this.fromDateTime(DateTime.parse('2018-10-20 ${timeOfDayString}Z'));

  bool isBefore(TimeOnly other) {
    return totalSeconds < other.totalSeconds;
  }

  bool isAfter(TimeOnly other) {
    return totalSeconds > other.totalSeconds;
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

  Duration toDuration() {
    return Duration(hours: hour, minutes: minute, seconds: second);
  }

  factory TimeOnly.fromJson(Map<String, dynamic> json) => _$TimeOnlyFromJson(json);

  Map<String, dynamic> toJson() => _$TimeOnlyToJson(this);

  static TypeConverter<TimeOnly, String> converter = TypeConverter.json(
    fromJson: (json) => TimeOnly.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
