import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'temperature_thresholds.g.dart';

@JsonSerializable()
class TemperatureThresholds {
  double? min;
  double? max;

  TemperatureThresholds();

  factory TemperatureThresholds.fromJson(Map<String, dynamic> json) => _$TemperatureThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureThresholdsToJson(this);

  static TypeConverter<TemperatureThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => TemperatureThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  bool exceeds(double? value) {
    if (value != null) {
      if (min != null && value < min!) {
        return true;
      }
      if (max != null && value > max!) {
        return true;
      }
    }

    return false;
  }
}
