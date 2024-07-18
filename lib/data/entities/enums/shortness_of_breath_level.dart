import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

enum ShortnessOfBreathLevel {
  @JsonValue('none')
  none(0),
  @JsonValue('low')
  low(10),
  @JsonValue('medium')
  medium(20),
  @JsonValue('high')
  high(30);

  final num value;

  const ShortnessOfBreathLevel(this.value);

  static ShortnessOfBreathLevel? fromValue(num? value) {
    return values.firstWhereOrNull((x) => x.value == value);
  }
}
