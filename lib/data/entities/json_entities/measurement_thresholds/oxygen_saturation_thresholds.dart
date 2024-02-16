import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oxygen_saturation_thresholds.g.dart';

@JsonSerializable()
class OxygenSaturationThresholds {
  int? percentageMin;
  int? percentageMax;

  OxygenSaturationThresholds(this.percentageMin, this.percentageMax);

  factory OxygenSaturationThresholds.fromJson(Map<String, dynamic> json) => _$OxygenSaturationThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$OxygenSaturationThresholdsToJson(this);

  static TypeConverter<OxygenSaturationThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => OxygenSaturationThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );
}
