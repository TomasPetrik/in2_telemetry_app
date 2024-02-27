import 'package:json_annotation/json_annotation.dart';

enum OverallHealthContract {
  @JsonValue('good')
  good(0),
  @JsonValue('variable')
  variable(10),
  @JsonValue('bad')
  bad(20),
  @JsonValue('veryBad')
  veryBad(30);

  final num value;

  const OverallHealthContract(this.value);
}
