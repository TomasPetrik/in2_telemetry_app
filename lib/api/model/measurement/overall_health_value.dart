import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'overall_health_value.g.dart';

@HiveType(typeId: 29)
enum OverallHealthValue {
  @JsonValue('Good')
  @HiveField(0)
  good(0),
  @JsonValue('Variable')
  @HiveField(10)
  variable(10),
  @JsonValue('Bad')
  @HiveField(20)
  bad(20),
  @JsonValue('VeryBad')
  @HiveField(30)
  veryBad(30);

  final num value;
  const OverallHealthValue(this.value);
}
