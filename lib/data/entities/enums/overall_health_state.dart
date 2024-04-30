import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

enum OverallHealthState {
  @JsonValue('good')
  good(0),
  @JsonValue('variable')
  low(10),
  @JsonValue('bad')
  medium(20),
  @JsonValue('veryBad')
  high(30);

  final num value;

  const OverallHealthState(this.value);

  static OverallHealthState? fromValue(num? value) {
    return values.firstWhereOrNull((x) => x.value == value);
  }
}
