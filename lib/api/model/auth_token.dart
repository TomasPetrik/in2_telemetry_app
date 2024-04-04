import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'auth_token.freezed.dart';

part 'auth_token.g.dart';

@unfreezed
class AuthToken with _$AuthToken {
  const AuthToken._();

  @HiveType(typeId: 7, adapterName: 'AuthTokenAdapter')
  const factory AuthToken(
    @HiveField(0) String accessToken,
    @HiveField(1) String refreshToken,
    @HiveField(2) DateTime accessTokenExpires,
  ) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);

  @override
  String toString() => toJson().toString();

  /// returns true when the token is either expired, or about to be expired
  bool isExpiring() {
    return DateTime.now()
        .add(const Duration(minutes: 5))
        .isAfter(accessTokenExpires);
  }
}
