import 'package:json_annotation/json_annotation.dart';

enum TimingDayWhenType {
  @JsonValue('TimeOfDay')
  timeOfDay,
  @JsonValue('When')
  when;
}
