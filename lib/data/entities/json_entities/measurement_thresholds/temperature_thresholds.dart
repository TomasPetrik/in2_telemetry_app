import 'package:json_annotation/json_annotation.dart';
import 'package:drift/drift.dart';

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
}
