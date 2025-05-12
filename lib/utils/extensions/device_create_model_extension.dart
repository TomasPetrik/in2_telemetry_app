import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

extension DeviceCreateModelExtension on DeviceCreateModel {

  String getDeviceTypeByMeasurementType() {
    final measurementType = prototype.supportedMeasurementTypes.first;
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
}