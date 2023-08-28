import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/configuration/configuration_base.dart';

class ProductionConfiguration extends BaseConfiguration {
  @override
  final List<Hospital> hospitals = [
    const Hospital(
      id: 0,
      title: 'Uherskohradišťská nemocnice',
      iconPath: 'assets/icons/icon_hospital_uhn.png',
      authData: AuthData(
        baseUrl: 'https://portal.nemuh.cz/api-mobile/v1',
        authUrl: 'https://portal-auth.nemuh.cz/connect/authorize',
        tokenUrl: 'https://portal-auth.nemuh.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    const Hospital(
      id: 1,
      title: 'Kroměřížská nemocnice',
      iconPath: 'assets/icons/icon_hospital_kmn.png',
      authData: AuthData(
        baseUrl: 'https://portal.nem-km.cz/api-mobile/v1',
        authUrl: 'https://portal-auth.nem-km.cz/connect/authorize',
        tokenUrl: 'https://portal-auth.nem-km.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    const Hospital(
      id: 2,
      title: 'Vsetínská nemocnice',
      iconPath: 'assets/icons/icon_hospital_vsn.png',
      authData: AuthData(
        baseUrl: 'https://portal.nemocnice-vs.cz/api-mobile/v1',
        authUrl: 'https://portal-auth.nemocnice-vs.cz/connect/authorize',
        tokenUrl: 'https://portal-auth.nemocnice-vs.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementTypeContract.bloodPressure, MeasurementTypeContract.heartRate],
    ),
    // TODO: Add URLs and uncomment #IN2-8308
    // const Hospital(
    //   id: 3,
    //   title: 'Krajská nemocnice Tomáše Bati ve Zlíně',
    //   iconPath: 'assets/icons/icon_hospital_kntb.svg',
    //   authData: AuthData(
    //     baseUrl: '???',
    //     authUrl: '???',
    //     tokenUrl: '???',
    //   ),
    // ),
  ];

  @override
  final String clientSecret = 'urHw0u2395TVg7lfEhKe';
}
