import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);

  @override
  String toString() => toJson().toString();

  bool isExpired() {
    return DateTime.now().isAfter(accessTokenExpires);
  }
}

@HiveType(typeId: 7)
class AuthTokenLocal extends HiveObject {
  @HiveField(0)
  final String refreshToken;

  @HiveField(1)
  final String accessToken;

  @HiveField(2)
  final DateTime expiresIn;

  AuthTokenLocal({
    required this.refreshToken,
    required this.accessToken,
    required this.expiresIn,
  });
}
