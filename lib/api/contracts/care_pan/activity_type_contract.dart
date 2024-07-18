import 'package:json_annotation/json_annotation.dart';

enum ActivityTypeContract {
  @JsonValue('Measurement')
  measurement,
  @JsonValue('Goal')
  goal;
}
