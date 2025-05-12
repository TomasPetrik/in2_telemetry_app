import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';

part 'shortness_of_breath_thresholds.g.dart';

@JsonSerializable()
class ShortnessOfBreathThresholds {
  ShortnessOfBreathLevel? max;

  ShortnessOfBreathThresholds(this.max);

  factory ShortnessOfBreathThresholds.fromJson(Map<String, dynamic> json) =>
      _$ShortnessOfBreathThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$ShortnessOfBreathThresholdsToJson(this);

  static TypeConverter<ShortnessOfBreathThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => ShortnessOfBreathThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  bool exceeds(ShortnessOfBreathLevel? value) {
    if (value != null) {
      if (max != null && value.value > max!.value) {
        return true;
      }
    }

    return false;
  }
}
