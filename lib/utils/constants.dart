import 'package:flutter/services.dart';
import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/model/measurement_config.dart';
import 'package:scalesoft_app/utils/input_formatters/decimal_text_input_formatter.dart';

class Constants {
  /* Background service interval fetch */
  static const int autoSyncIntervalMinutes = 15;

  /* API */
  static const String privateDioName = 'privateDio';

  /* Default Location (Prague) to get sunset / sunrise for autoswith appearance */
  static const double defaultLat = 50.08804;
  static const double defaultLng = 14.42076;

  /* OAuth2 */
  static const String clientSecret = 'cqWFWo9zYQHFh38kS8VC';
  static const String clientId = 'MobileApp';
  static const List<String> scopes = [
    'openid',
    'profile',
    'offline_access',
    'mobile_api.Default',
  ];
  static const String redirectUrl = 'cz.scalesoft.tlm://auth-callback';

  /* Enviroments */
  static const List<Hospital> hospitals = [
    Hospital(
      id: 0,
      title: 'in2-win',
      iconPath: 'assets/icons/icon_hospital_ikem.svg',
      authData: AuthData(
        baseUrl: 'https://in2-win.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-win-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-win-auth.devscale.cz/connect/token',
      ),
    ),
    Hospital(
      id: 1,
      title: 'in2-test',
      iconPath: 'assets/icons/icon_hospital_nahomolce.svg',
      authData: AuthData(
        baseUrl: 'https://in2-test.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-test-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-test-auth.devscale.cz/connect/token',
      ),
    ),
    Hospital(
      id: 2,
      title: 'in2',
      iconPath: 'assets/icons/icon_hospital_user.svg',
      authData: AuthData(
        baseUrl: 'https://in2.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-auth.devscale.cz/connect/token',
      ),
    ),
  ];

  /* Supported Measurements */

  static Map<MeasurementType, MeasurementConfig> supportedMeasurements = {
    MeasurementType.bloodPressure: MeasurementConfig(
      MeasurementConfigType.composed,
      ['mmHg', 'mmHg'],
      [UnitName.systolic, UnitName.diastolic],
      30,
      300,
      TextInputType.number,
      ['0', '0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3)
      ],
    ),
    MeasurementType.temperature: MeasurementConfig(
      MeasurementConfigType.single,
      ['°C'],
      [UnitName.temperature],
      30,
      45,
      const TextInputType.numberWithOptions(decimal: true),
      ['0'],
      [DecimalTextInputFormatter(1)],
    ),
    MeasurementType.heartRate: MeasurementConfig(
      MeasurementConfigType.single,
      ['TF'],
      [UnitName.pulse],
      30,
      250,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3)
      ],
    ),
    MeasurementType.oxygenSaturation: MeasurementConfig(
      MeasurementConfigType.single,
      ['%'],
      [UnitName.oxygenSaturation],
      50,
      100,
      const TextInputType.numberWithOptions(decimal: true),
      ['0'],
      [DecimalTextInputFormatter(1)],
    ),
    MeasurementType.respiratoryRate: MeasurementConfig(
      MeasurementConfigType.single,
      null,
      [UnitName.respiratoryRate],
      5,
      60,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3)
      ],
    ),
    MeasurementType.steps: MeasurementConfig(
      MeasurementConfigType.single,
      null,
      [UnitName.steps],
      0,
      1000000,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10)
      ],
    ),
    MeasurementType.globalPosition: MeasurementConfig(
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
    MeasurementType.ews: MeasurementConfig(
      MeasurementConfigType.single,
      null,
      [UnitName.ews],
      0,
      10,
      TextInputType.number,
      ['0'],
      [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2)
      ],
    ),
  };

  /* Supported Devices */

  static const List<Device> supportedDevices = [
    Device(
      localId: 0,
      modelName: 'BM77',
      deviceManufacturer: 'Beurer',
      visibleName: 'Beurer BM 77',
      bluetoothName: 'BM77',
      deviceModelType: DeviceModelType.beurerBm77,
      imagePath: 'assets/images/beurer_bm_77.png',
      supportedMeasurementTypes: [
        MeasurementType.bloodPressure,
        MeasurementType.heartRate,
      ],
      reqPairing: false,
      askToActivateBt: true,
      askToConfirmMeasurement: true,
      actionButtonType: ActionButtonType.regular,
    ),
    Device(
      localId: 1,
      modelName: 'M7',
      deviceManufacturer: "Omron",
      visibleName: 'Omron M7',
      bluetoothName: 'BLESmart',
      deviceModelType: DeviceModelType.omronM7,
      imagePath: 'assets/images/omron_m7.png',
      supportedMeasurementTypes: [
        MeasurementType.bloodPressure,
        MeasurementType.heartRate,
      ],
      reqPairing: true,
      actionButtonType: ActionButtonType.startButton,
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
    12: 'dec'
  };
}
