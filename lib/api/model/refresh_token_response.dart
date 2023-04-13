import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_response.freezed.dart';
part 'refresh_token_response.g.dart';

@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  factory RefreshTokenResponse(
    @JsonKey(name: 'id_token') String imodelken,
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String refreshToken,
    @JsonKey(name: 'expires_in') int expiresIn,
    @JsonKey(name: 'token_type') String tokenType,
    String scope,
  ) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  @override
  String toString() => toJson().toString();
}
