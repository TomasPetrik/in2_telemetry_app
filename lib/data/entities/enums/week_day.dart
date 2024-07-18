import 'package:freezed_annotation/freezed_annotation.dart';

enum WeekDay {
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
  sunday;
}
