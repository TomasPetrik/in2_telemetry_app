import 'package:json_annotation/json_annotation.dart';
import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';

part 'overall_health_thresholds.g.dart';

@JsonSerializable()
class OverallHealthThresholds {
  OverallHealthState max;

  OverallHealthThresholds(this.max);

  factory OverallHealthThresholds.fromJson(Map<String, dynamic> json) => _$OverallHealthThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$OverallHealthThresholdsToJson(this);

  static TypeConverter<OverallHealthThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => OverallHealthThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );
}
