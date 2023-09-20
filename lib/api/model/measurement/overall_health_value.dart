import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'overall_health_value.hive.dart';

@HiveType(typeId: 29)
enum OverallHealthValue {
  @JsonValue('good')
  @HiveField(0)
  good,
  @JsonValue('variable')
  @HiveField(10)
  variable,
  @JsonValue('bad')
  @HiveField(20)
  bad,
  @JsonValue('veryBad')
  @HiveField(30)
  veryBad,
}
