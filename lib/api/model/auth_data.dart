class AuthData {
  final String baseUrl;
  final String authUrl;
  final String tokenUrl;
  final String? codeVerifier;

  const AuthData({
    required this.baseUrl,
    required this.authUrl,
    required this.tokenUrl,
    this.codeVerifier,
  });
}
