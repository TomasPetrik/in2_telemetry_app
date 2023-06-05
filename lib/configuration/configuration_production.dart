import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/configuration/configuration_base.dart';

class ProductionConfiguration extends BaseConfiguration {
  @override
  final List<Hospital> hospitals = [
    const Hospital(
      id: 0,
      title: 'in2-win',
      iconPath: 'assets/icons/icon_hospital_ikem.svg',
      authData: AuthData(
        baseUrl: 'https://in2-win.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-win-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-win-auth.devscale.cz/connect/token',
      ),
    ),
    const Hospital(
      id: 1,
      title: 'in2-test',
      iconPath: 'assets/icons/icon_hospital_nahomolce.svg',
      authData: AuthData(
        baseUrl: 'https://in2-test.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-test-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-test-auth.devscale.cz/connect/token',
      ),
    ),
    const Hospital(
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

  @override
  // TODO: This should be different from staging
  final String clientSecret = 'cqWFWo9zYQHFh38kS8VC';
}
