//CCC
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';

const ccc = "00002902-0000-1000-8000-00805f9b34fb";

//Services UUIDs

const Map<MeasurementType, String> serviceUuids = {
  MeasurementType.heartRate: temperatureServiceUuid,
  MeasurementType.bloodPressure: bloodPressureServiceUuid,
  MeasurementType.temperature: hearthRateServiceUuid,
};

const temperatureServiceUuid = "1809";
const bloodPressureServiceUuid = "1810";
const hearthRateServiceUuid = "180D";

//const bloodPressureUuid = "00001810-0000-1000-8000-00805f9b34fb";
const batteryServiceUuid = "0000180F-0000-1000-8000-00805f9b34fb";

// Characteristics UUIDs
const bloodPressureMeasurementCharUuid = "00002A35-0000-1000-8000-00805f9b34fb";
const bloodPressureFeatureCharUuid = "00002A49-0000-1000-8000-00805f9b34fb";
const batteryServCharUuid = "00002A19-0000-1000-8000-00805f9b34fb";
