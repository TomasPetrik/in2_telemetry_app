import 'package:json_annotation/json_annotation.dart';

enum ShortnessOfBreathContract {
  @JsonValue('None')
  none(0),
  @JsonValue('Low')
  low(10),
  @JsonValue('Medium')
  medium(20),
  @JsonValue('High')
  high(30);

  final num value;

  const ShortnessOfBreathContract(this.value);
}
