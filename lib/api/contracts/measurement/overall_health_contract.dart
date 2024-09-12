import 'package:json_annotation/json_annotation.dart';

enum OverallHealthContract {
  @JsonValue('Good')
  good(0),
  @JsonValue('Variable')
  variable(10),
  @JsonValue('Bad')
  bad(20),
  @JsonValue('VeryBad')
  veryBad(30);

  final num value;

  const OverallHealthContract(this.value);
}
