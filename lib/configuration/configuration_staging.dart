import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/configuration/configuration_base.dart';

class StagingConfiguration extends BaseConfiguration {
  @override
  final List<Hospital> hospitals = [
    const Hospital(
      id: 0,
      title: 'in2-win (but more staging)',
      iconPath: 'assets/icons/icon_hospital_ikem.svg',
      authData: AuthData(
        baseUrl: 'https://in2-win.devscale.cz/api-mobile/v1',
        authUrl: 'https://in2-win-auth.devscale.cz/connect/authorize',
        tokenUrl: 'https://in2-win-auth.devscale.cz/connect/token',
      ),
    ),
  ];

  @override
  final String clientSecret = 'cqWFWo9zYQHFh38kS8VC';
}
