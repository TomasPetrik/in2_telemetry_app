import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

enum MeasurementType {
  @JsonValue('Temperature')
  temperature(),
  @JsonValue('BloodPressure')
  bloodPressure,
  @JsonValue('OxygenSaturation')
  oxygenSaturation,
  @JsonValue('Steps')
  steps,
  @JsonValue('GlobalPosition')
  globalPosition,
  @JsonValue('HeartRate')
  heartRate,
  @JsonValue('Ews')
  ews,
  @JsonValue('RespiratoryRate')
  respiratoryRate,
  @JsonValue('ShortnessOfBreath')
  shortnessOfBreath,
  @JsonValue('OverallHealth')
  overallHealth,
  @JsonValue('Battery')
  battery;
}

String getDeviceTypeByMeasurementType(DeviceCreateModel device) {
  final measurementType = device.prototype.supportedMeasurementTypes.first;
  switch (measurementType) {
    case MeasurementType.temperature:
      return localization.device_thermometer;
    case MeasurementType.bloodPressure:
      return localization.device_tonometer;
    case MeasurementType.oxygenSaturation:
      return localization.device_oximetry;
    default:
      return localization.device_generic;
  }
}
