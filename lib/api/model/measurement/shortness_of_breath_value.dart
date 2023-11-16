import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'shortness_of_breath_value.g.dart';

@HiveType(typeId: 28)
enum ShortnessOfBreathValue {
  @JsonValue('none')
  @HiveField(0)
  none,
  @JsonValue('low')
  @HiveField(10)
  low,
  @JsonValue('medium')
  @HiveField(20)
  medium,
  @JsonValue('high')
  @HiveField(30)
  high,
}
