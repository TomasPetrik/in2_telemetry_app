import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

@singleton
class AuthService {
  AuthorizationCodeGrant getAuthGrant(
    String clientId,
    String clientSecret,
    String authorizationEndpoint,
    String tokenEndpoint, [
    String? codeVerifier,
  ]) {
    final grant = AuthorizationCodeGrant(
      clientId,
      Uri.parse(authorizationEndpoint),
      Uri.parse(tokenEndpoint),
      secret: clientSecret,
      codeVerifier: codeVerifier,
    );

    return grant;
  }

  Future<Client?> authorize(
    AuthorizationCodeGrant grant,
    List<String> scopes,
    String redirectUrl,
  ) async {
    final authUri = grant.getAuthorizationUrl(
      Uri.parse(redirectUrl),
      scopes: scopes,
    );

    final newQueryParameters = {
      '_tstamp': '${DateTime.now().microsecondsSinceEpoch}',
      'prompt': 'login',
    };

    final newAuthUri = authUri.replace(
      queryParameters: Map.from(authUri.queryParameters)
        ..addAll(newQueryParameters),
    );

    if (await canLaunchUrl(newAuthUri)) {
      await launchUrl(
        newAuthUri,
        mode: LaunchMode.inAppBrowserView,
        webOnlyWindowName: '_blank',
      );
    }

    linkStream.listen(
      (String? link) {},
      onError: (err) {},
    );

    final responseUrl = await linkStream.first;

    if (responseUrl != null) {
      await closeInAppWebView();
      final tokenResponse = await grant.handleAuthorizationResponse(
        Uri.parse(responseUrl).queryParameters,
      );
      return tokenResponse;
    } else {
      return null;
    }
  }

  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  String createCodeVerifier() => List.generate(
        128,
        (i) => _charset[Random.secure().nextInt(_charset.length)],
      ).join();
}
