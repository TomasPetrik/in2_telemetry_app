import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'heart_rate_thresholds.g.dart';

@JsonSerializable()
class HeartRateThresholds {
  int? min;
  int? max;

  HeartRateThresholds(this.min, this.max);

  factory HeartRateThresholds.fromJson(Map<String, dynamic> json) => _$HeartRateThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateThresholdsToJson(this);

  static TypeConverter<HeartRateThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => HeartRateThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  bool exceeds(int? heartRate) {
    if (heartRate != null) {
      if (min != null && heartRate < min!) {
        return true;
      }
      if (max != null && heartRate > max!) {
        return true;
      }
    }

    return false;
  }
}
