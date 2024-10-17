import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/model/hospital.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

class HospitalsConfiguration {
  static List<Hospital> hospitals = [
    const Hospital(
      id: 0,
      title: 'Uherskohradišťská nemocnice',
      iconPath: 'assets/icons/icon_hospital_uhn.png',
      authData: AuthData(
        baseUrl: 'https://portal.nemuh.cz/api-mobile/v1',
        authUrl: 'https://portal-auth.nemuh.cz/connect/authorize',
        tokenUrl: 'https://portal-auth.nemuh.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      clientSecret: 'urHw0u2395TVg7lfEhKe',
    ),
    const Hospital(
      id: 1,
      title: '[Test] Uherskohradišťská nemocnice',
      iconPath: 'assets/icons/icon_hospital_uhn.png',
      authData: AuthData(
        baseUrl: 'https://portal-test.nemuh.cz/api-mobile/v1',
        authUrl: 'https://portal-test-auth.nemuh.cz/connect/authorize',
        tokenUrl: 'https://portal-test-auth.nemuh.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
    const Hospital(
      id: 2,
      title: 'Kroměřížská nemocnice',
      iconPath: 'assets/icons/icon_hospital_kmn.png',
      authData: AuthData(
        baseUrl: 'https://portal.nem-km.cz/api-mobile/v1',
        authUrl: 'https://portal-auth.nem-km.cz/connect/authorize',
        tokenUrl: 'https://portal-auth.nem-km.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      clientSecret: 'urHw0u2395TVg7lfEhKe',
    ),
    const Hospital(
      id: 3,
      title: '[Test] Kroměřížská nemocnice',
      iconPath: 'assets/icons/icon_hospital_kmn.png',
      authData: AuthData(
        baseUrl: 'https://portal-test.nem-km.cz/api-mobile/v1',
        authUrl: 'https://portal-test-auth.nem-km.cz/connect/authorize',
        tokenUrl: 'https://portal-test-auth.nem-km.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
    const Hospital(
      id: 4,
      title: 'Vsetínská nemocnice',
      iconPath: 'assets/icons/icon_hospital_vsn.png',
      authData: AuthData(
        baseUrl: 'https://portal.nemocnice-vs.cz/api-mobile/v1',
        authUrl: 'https://portal-auth.nemocnice-vs.cz/connect/authorize',
        tokenUrl: 'https://portal-auth.nemocnice-vs.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      clientSecret: 'urHw0u2395TVg7lfEhKe',
    ),
    const Hospital(
      id: 5,
      title: '[Test] Vsetínská nemocnice',
      iconPath: 'assets/icons/icon_hospital_vsn.png',
      authData: AuthData(
        baseUrl: 'https://portal-test.nemocnice-vs.cz/api-mobile/v1',
        authUrl: 'https://portal-auth-test.nemocnice-vs.cz/connect/authorize',
        tokenUrl: 'https://portal-auth-test.nemocnice-vs.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
    const Hospital(
      id: 6,
      title: 'Krajská nemocnice T. Bati',
      iconPath: 'assets/icons/icon_hospital_kntb.svg',
      authData: AuthData(
        baseUrl: 'https://e-health.bnzlin.cz/api-mobile/v1',
        authUrl: 'https://e-health-auth.bnzlin.cz/connect/authorize',
        tokenUrl: 'https://e-health-auth.bnzlin.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      clientSecret: 'urHw0u2395TVg7lfEhKe',
    ),
    const Hospital(
      id: 7,
      title: '[Test] Krajská nemocnice T. Bati',
      iconPath: 'assets/icons/icon_hospital_kntb.svg',
      authData: AuthData(
        baseUrl: 'https://e-health-test.bnzlin.cz/api-mobile/v1',
        authUrl: 'https://e-health-test-auth.bnzlin.cz/connect/authorize',
        tokenUrl: 'https://e-health-test-auth.bnzlin.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.bloodPressure, MeasurementType.heartRate],
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
    const Hospital(
      id: 8,
      title: 'Klaudiánova Nemocnice',
      iconPath: 'assets/icons/icon_hospital_onmb.png',
      authData: AuthData(
        baseUrl: 'https://pacient.onmb.cz/api-mobile/v1',
        authUrl: 'https://pacient-auth.onmb.cz/connect/authorize',
        tokenUrl: 'https://pacient-auth.onmb.cz/connect/token',
      ),
      enabledMeasurementTypes: [MeasurementType.shortnessOfBreath, MeasurementType.overallHealth],
      clientSecret: 'urHw0u2395TVg7lfEhKe',
    ),
    Hospital(
      id: 9,
      title: '[Test] in2-win',
      iconPath: 'assets/icons/icon_hospital_user.svg',
      authData: const AuthData(
        baseUrl: 'https://in2-win.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-win-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-win-auth.devscale.cz/connect/token',
      ),
      enabledMeasurementTypes: MeasurementType.values
          .where(
            (x) => ![MeasurementType.globalPosition, MeasurementType.battery].any((y) => y == x),
          )
          .toList(),
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
    Hospital(
      id: 10,
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
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
    const Hospital(
      id: 11,
      title: '[Test] STAPRO Showroom',
      iconPath: 'assets/icons/icon_hospital_user.svg',
      authData: AuthData(
        baseUrl: 'https://fonscare.stapro.cz/api-mobile/v1',
        authUrl: 'https://fonscare-auth.stapro.cz/connect/authorize',
        tokenUrl: 'https://fonscare-auth.stapro.cz/connect/token',
      ),
      enabledMeasurementTypes: [
        MeasurementType.temperature,
        MeasurementType.bloodPressure,
        MeasurementType.oxygenSaturation,
        MeasurementType.heartRate,
        MeasurementType.shortnessOfBreath,
        MeasurementType.overallHealth,
      ],
      isStaging: true,
      clientSecret: 'cqWFWo9zYQHFh38kS8VC',
    ),
  ];

  static String logEndpointSecret = 'zvqoz0vA#agIA0rsIzYSuk7kU1sCfKK6hsVYP3dW6!AOj**^31';

  static String clientId = 'MobileApp';

  static List<String> scopes = [
    'openid',
    'profile',
    'offline_access',
    'mobile_api.Default',
  ];

  static String redirectUrl = 'cz.scalesoft.tlm://auth-callback';
}
