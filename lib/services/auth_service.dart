import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';

@singleton
class AuthService {
  AuthorizationCodeGrant getAuthGrant(
    String clientId,
    String clientSecret,
    String authorizationEndpoint,
    String tokenEndpoint,
  ) {
    final grant = oauth2.AuthorizationCodeGrant(
      clientId,
      Uri.parse(authorizationEndpoint),
      Uri.parse(tokenEndpoint),
      secret: clientSecret,
    );

    return grant;
  }
}
