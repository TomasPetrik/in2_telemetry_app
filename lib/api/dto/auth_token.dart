import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token.freezed.dart';
part 'auth_token.g.dart';

@freezed
class AuthToken with _$AuthToken {
  const AuthToken._();

  factory AuthToken({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpires,
  }) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) => _$AuthTokenFromJson(json);

  @override
  String toString() => toJson().toString();

  bool isExpired() {
    return DateTime.now().isAfter(accessTokenExpires);
  }
}
