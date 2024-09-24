import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'shortness_of_breath_value.g.dart';

@HiveType(typeId: 28)
enum ShortnessOfBreathValue {
  @JsonValue('None')
  @HiveField(0)
  none(0),
  @JsonValue('Low')
  @HiveField(10)
  low(10),
  @JsonValue('Medium')
  @HiveField(20)
  medium(20),
  @JsonValue('High')
  @HiveField(30)
  high(30);

  final num value;
  const ShortnessOfBreathValue(this.value);
}
