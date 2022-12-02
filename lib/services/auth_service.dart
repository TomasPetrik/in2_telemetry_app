import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

@singleton
class AuthService {
  Future<Client?> authorize(
    Uri uri,
    String clientId,
    List<String> scopes,
    String redirectUrl,
    String clientSecret,
    String authorizationEndpoint,
    String tokenEndpoint,
    String endSessionEndpoint,
  ) async {
    final grant = oauth2.AuthorizationCodeGrant(
      clientId,
      Uri.parse(authorizationEndpoint),
      Uri.parse(tokenEndpoint),
      secret: clientSecret,
    );

    final authorizationUrl = grant.getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes);

    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication);
    }

    linkStream.listen(
      (String? link) {},
      onError: (err) {},
    );

    final responseUrl = await linkStream.first;
    if (responseUrl == null) {
      return null;
    }

    return await grant.handleAuthorizationResponse(Uri.parse(responseUrl).queryParameters);
  }
}
