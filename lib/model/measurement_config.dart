import 'package:flutter/services.dart';

class MeasurementConfig {
  final MeasurementConfigType type;
  final List<String>? units;

  final List<UnitName> unitNames;
  final double? min;
  final double? max;
  final TextInputType? textInputType;
  final List<String>? hintText;
  final List<TextInputFormatter>? inputFormatters;

  MeasurementConfig(
    this.type,
    this.units,
    this.unitNames,
    this.min,
    this.max,
    this.textInputType,
    this.hintText,
    this.inputFormatters,
  );
}

enum MeasurementConfigType {
  single,
  composed,
  select,
}

enum UnitName {
  systolic,
  diastolic,
  temperature,
  pulse,
  oxygenSaturation,
  respiratoryRate,
  steps,
  lat,
  lng,
  ews,
  shortnessOfBreath,
  overallHealth,
}
