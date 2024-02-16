import 'package:json_annotation/json_annotation.dart';

enum TimeUnit {
  @JsonValue('hour')
  hour,
  @JsonValue('day')
  day,
  @JsonValue('week')
  week,
  @JsonValue('month')
  month,
  @JsonValue('year')
  year;
}