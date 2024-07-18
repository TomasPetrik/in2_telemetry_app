import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

enum OverallHealthState {
  @JsonValue('good')
  good(0),
  @JsonValue('variable')
  variable(10),
  @JsonValue('bad')
  bad(20),
  @JsonValue('veryBad')
  veryBad(30);

  final num value;

  const OverallHealthState(this.value);

  static OverallHealthState? fromValue(num? value) {
    return values.firstWhereOrNull((x) => x.value == value);
  }
}
