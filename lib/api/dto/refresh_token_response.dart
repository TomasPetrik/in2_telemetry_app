import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_response.freezed.dart';
part 'refresh_token_response.g.dart';

@freezed
//@JsonSerializable(explicitToJson: true)
class RefreshTokenResponse with _$RefreshTokenResponse {
  factory RefreshTokenResponse({required String accessToken, required String refreshToken}) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) => _$RefreshTokenResponseFromJson(json);

  @override
  String toString() => toJson().toString();
}
