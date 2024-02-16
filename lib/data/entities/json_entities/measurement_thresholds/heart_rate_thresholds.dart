import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'heart_rate_thresholds.g.dart';

@JsonSerializable()
class HeartRateThresholds {
  int? percentageMin;
  int? percentageMax;

  HeartRateThresholds(this.percentageMin, this.percentageMax);

  factory HeartRateThresholds.fromJson(Map<String, dynamic> json) => _$HeartRateThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateThresholdsToJson(this);

  static TypeConverter<HeartRateThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => HeartRateThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );
}
