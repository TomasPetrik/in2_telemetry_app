import 'package:json_annotation/json_annotation.dart';

enum TimingDayWhenTypeContract {
  @JsonValue('TimeOfDay')
  timeOfDay,
  @JsonValue('When')
  when;
}
