import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'overall_health_value.hive.dart';

@HiveType(typeId: 29)
enum OverallHealthValue {
  @JsonValue('good')
  @HiveField(0)
  good(0),
  @JsonValue('variable')
  @HiveField(10)
  variable(10),
  @JsonValue('bad')
  @HiveField(20)
  bad(20),
  @JsonValue('veryBad')
  @HiveField(30)
  veryBad(30);

  final num value;
  const OverallHealthValue(this.value);
}
