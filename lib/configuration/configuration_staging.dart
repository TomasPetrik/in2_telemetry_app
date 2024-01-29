import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/configuration/configuration_base.dart';

class StagingConfiguration extends BaseConfiguration {
  @override
  final List<Hospital> hospitals = [
    const Hospital(
      id: 0,
      title: '[Test] Uherskohradišťská nemocnice',
      iconPath: 'assets/icons/icon_hospital_uhn.png',
      authData: AuthData(
        baseUrl: 'https://portal-test.nemuh.cz/api-mobile/v1',
        authUrl: 'https://portal-test-auth.nemuh.cz/connect/authorize',
        tokenUrl: 'https://portal-test-auth.nemuh.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    const Hospital(
      id: 1,
      title: '[Test] Kroměřížská nemocnice',
      iconPath: 'assets/icons/icon_hospital_kmn.png',
      authData: AuthData(
        baseUrl: 'https://portal-test.nem-km.cz/api-mobile/v1',
        authUrl: 'https://portal-test-auth.nem-km.cz/connect/authorize',
        tokenUrl: 'https://portal-test-auth.nem-km.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    const Hospital(
      id: 2,
      title: '[Test] Vsetínská nemocnice',
      iconPath: 'assets/icons/icon_hospital_vsn.png',
      authData: AuthData(
        baseUrl: 'https://portal-test.nemocnice-vs.cz/api-mobile/v1',
        authUrl: 'https://portal-auth-test.nemocnice-vs.cz/connect/authorize',
        tokenUrl: 'https://portal-auth-test.nemocnice-vs.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    const Hospital(
      id: 3,
      title: '[Test] Krajská nemocnice T. Bati',
      iconPath: 'assets/icons/icon_hospital_kntb.svg',
      authData: AuthData(
        baseUrl: 'https://e-health-test.bnzlin.cz/api-mobile/v1',
        authUrl: 'https://e-health-test-auth.bnzlin.cz/connect/authorize',
        tokenUrl: 'https://e-health-test-auth.bnzlin.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    // TODO: Add URLs and uncomment #IN2-8308
    // const Hospital(
    //   id: 3,
    //   title: '[Test] Krajská nemocnice Tomáše Bati ve Zlíně',
    //   iconPath: 'assets/icons/icon_hospital_kntb.svg',
    //   authData: AuthData(
    //     baseUrl: '???',
    //     authUrl: '???',
    //     tokenUrl: '???',
    //   ),
    // ),
    Hospital(
      id: 4,
      title: '[Test] in2-win',
      iconPath: 'assets/icons/icon_hospital_user.svg',
      authData: const AuthData(
        baseUrl: 'https://in2-win.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-win-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-win-auth.devscale.cz/connect/token',
      ),
      enabledMeasurementTypes: MeasurementTypeContract.values
          .where(
            (x) => x != MeasurementTypeContract.battery,
          )
          .toList(),
    ),
    Hospital(
      id: 4,
      title: '[Test] in2',
      iconPath: 'assets/icons/icon_hospital_user.svg',
      authData: const AuthData(
        baseUrl: 'https://in2.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-auth.devscale.cz/connect/token',
      ),
      enabledMeasurementTypes: MeasurementType.values
          .where(
            (x) => ![MeasurementType.globalPosition, MeasurementType.battery].any((y) => y == x),
          )
          .toList(),
    ),
  ];

  @override
  final String clientSecret = 'cqWFWo9zYQHFh38kS8VC';

  @override
  final String logEndpointSecret = 'zvqoz0vA#agIA0rsIzYSuk7kU1sCfKK6hsVYP3dW6!AOj**^31';
}
