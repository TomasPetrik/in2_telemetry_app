import 'package:flutter/services.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/model/measurement_config.dart';
import 'package:scalesoft_app/utils/input_formatters/decimal_text_input_formatter.dart';

class ConfigurationConstants {
  /* Keep debug logs max for N days */
  static const int keepLogsDays = 2;

  /* Background service interval fetch */
  static const int autoSyncIntervalMinutes = 15;

  /* Max allowed waiting time for searching device */
  static const Duration maxAllowedDeviceSearchingTime = Duration(seconds: 10);

  /* API */
  static const String privateDioName = 'privateDio';

  /* Supported Measurements */

  static Map<MeasurementTypeContract, MeasurementConfig> supportedMeasurements = {
    MeasurementTypeContract.bloodPressure: MeasurementConfig(
      MeasurementConfigType.composed,
      ['mmHg', 'mmHg'],
      [UnitName.systolic, UnitName.diastolic],
      30,
      300,
      TextInputType.number,
      ['0', '0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
    ),
    MeasurementTypeContract.temperature: MeasurementConfig(
      MeasurementConfigType.single,
      ['°C'],
      [UnitName.temperature],
      30,
      45,
      const TextInputType.numberWithOptions(decimal: true),
      ['0'],
      [DecimalTextInputFormatter(1)],
    ),
    MeasurementTypeContract.heartRate: MeasurementConfig(
      MeasurementConfigType.single,
      ['TF'],
      [UnitName.pulse],
      30,
      250,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
    ),
    MeasurementTypeContract.oxygenSaturation: MeasurementConfig(
      MeasurementConfigType.single,
      ['%'],
      [UnitName.oxygenSaturation],
      50,
      100,
      const TextInputType.numberWithOptions(decimal: true),
      ['0'],
      [DecimalTextInputFormatter(1)],
    ),
    MeasurementTypeContract.respiratoryRate: MeasurementConfig(
      MeasurementConfigType.single,
      null,
      [UnitName.respiratoryRate],
      5,
      60,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
    ),
    MeasurementTypeContract.steps: MeasurementConfig(
      MeasurementConfigType.single,
      null,
      [UnitName.steps],
      0,
      1000000,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    ),
    MeasurementTypeContract.globalPosition: MeasurementConfig(
      MeasurementConfigType.composed,
      null,
      [UnitName.lat, UnitName.lng],
      -100,
      100,
      const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      ['48.2389', '17.3693'],
      [DecimalTextInputFormatter(12), LengthLimitingTextInputFormatter(15)],
    ),
    MeasurementTypeContract.ews: MeasurementConfig(
      MeasurementConfigType.single,
      null,
      [UnitName.ews],
      0,
      23,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
    ),
    MeasurementType.shortnessOfBreath: MeasurementConfig(
      MeasurementConfigType.select,
      null,
      [UnitName.shortnessOfBreath],
      null,
      null,
      null,
      null,
      null,
    ),
    MeasurementType.overallHealth: MeasurementConfig(
      MeasurementConfigType.select,
      null,
      [UnitName.overallHealth],
      null,
      null,
      null,
      null,
      null,
    ),
  };

  /* Supported measurement types */

  static const Set<MeasurementTypeContract> supportedMeasurementTypes = {
    MeasurementTypeContract.bloodPressure,
  };

  /* EGoverment authorization */

  /* Supported Devices */

  static final List<Device> supportedDevices = [
    Device(
      localId: 0,
      modelName: 'BM77',
      deviceManufacturer: 'Beurer',
      visibleName: 'Beurer BM 77',
      bluetoothName: 'BM77',
      bluetoothPairingName: 'BM77',
      deviceModelType: DeviceModelType.beurerBm77,
      imagePath: 'assets/images/beurer_bm_77.png',
      supportedMeasurementTypes: [
        MeasurementTypeContract.bloodPressure,
        MeasurementTypeContract.heartRate,
      ],
      reqPairing: false,
      askToActivateBt: true,
      askToConfirmMeasurement: true,
      actionButtonType: ActionButtonType.regular,
      measurementFlow: MeasurementFlow.foreground,
    ),
    Device(
      localId: 1,
      modelName: 'M7',
      deviceManufacturer: "Omron",
      visibleName: 'Omron M7',
      bluetoothName: 'BLESmart',
      bluetoothPairingName: 'BLEsmart',
      deviceModelType: DeviceModelType.omronM7,
      imagePath: 'assets/images/omron_m7.png',
      supportedMeasurementTypes: [
        MeasurementTypeContract.bloodPressure,
        MeasurementTypeContract.heartRate,
      ],
      reqPairing: true,
      actionButtonType: ActionButtonType.startButton,
      measurementFlow: MeasurementFlow.foreground,
    ),
    Device(
      localId: 2,
      modelName: 'E86',
      visibleName: "E86",
      bluetoothName: "E86",
      deviceModelType: DeviceModelType.e8x,
      supportedMeasurementTypes: [
        MeasurementType.temperature,
        MeasurementType.heartRate,
        MeasurementType.bloodPressure,
        MeasurementType.oxygenSaturation,
        MeasurementType.respiratoryRate,
      ],
      imagePath: 'assets/images/e8x.png',
      measurementFlow: MeasurementFlow.background,
    ),
  ];

  static const Map<int, String> monthsInYear = {
    1: 'jan',
    2: 'feb',
    3: 'march',
    4: 'april',
    5: 'may',
    6: 'june',
    7: 'july',
    8: 'aug',
    9: 'sept',
    10: 'oct',
    11: 'nov',
    12: 'dec',
  };
}
