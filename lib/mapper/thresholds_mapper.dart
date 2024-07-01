import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/blood_pressure_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/heart_rate_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/measurement_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/overall_health_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/oxygen_saturation_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/shortness_of_breath_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/temperature_thresholds_contract.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/blood_pressure_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/heart_rate_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/overall_health_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/oxygen_saturation_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/shortness_of_breath_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/temperature_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/measurement_thresholds.dart';

import 'package:scalesoft_app/mapper/thresholds_mapper.auto_mappr.dart';

@injectable
@AutoMappr([
  MapType<MeasurementThresholdsContract, MeasurementThresholds>(
    whenSourceIsNull: null,
  ),
  MapType<BloodPressureThresholdsContract, BloodPressureThresholds>(),
  MapType<HeartRateThresholdsContract, HeartRateThresholds>(),
  MapType<OxygenSaturationThresholdsContract, OxygenSaturationThresholds>(
    fields: [
      Field('percentageMin', custom: ThresholdsMapper.mapMinPercentage),
      Field('percentageMax', custom: ThresholdsMapper.mapMaxPercentage)
    ],
  ),
  MapType<TemperatureThresholdsContract, TemperatureThresholds>(),
  MapType<ShortnessOfBreathThresholdsContract, ShortnessOfBreathThresholds>(),
  MapType<OverallHealthThresholdsContract, OverallHealthThresholds>(),
  MapType<OverallHealthContract, OverallHealthState>(),
  MapType<ShortnessOfBreathContract, ShortnessOfBreathLevel>(),
])
class ThresholdsMapper extends $ThresholdsMapper {
  static int? mapMinPercentage(OxygenSaturationThresholdsContract contract) {
    return contract.percentageMin?.round();
  }

  static int? mapMaxPercentage(OxygenSaturationThresholdsContract contract) {
    return contract.percentageMax?.round();
  }
}
