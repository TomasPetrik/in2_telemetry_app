import 'package:scalesoft_app/model/hospital.dart';

abstract class BaseConfiguration {
  abstract final List<Hospital> hospitals;

  /* OAuth2 */
  abstract final String clientSecret;
  final String clientId = 'MobileApp';
  final List<String> scopes = [
    'openid',
    'profile',
    'offline_access',
    'mobile_api.Default',
  ];
  final String redirectUrl = 'cz.scalesoft.tlm://auth-callback';
  abstract final String logEndpointSecret;
}
