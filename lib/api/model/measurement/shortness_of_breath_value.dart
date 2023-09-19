import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'shortness_of_breath_value.hive.dart';

@HiveType(typeId: 28)
enum ShortnessOfBreathValue {
  @JsonValue('none')
  @HiveField(0)
  none,
  @JsonValue('low')
  @HiveField(1)
  low,
  @JsonValue('medium')
  @HiveField(2)
  medium,
  @JsonValue('high')
  @HiveField(3)
  high,
}
