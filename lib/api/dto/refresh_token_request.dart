import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_request.freezed.dart';
part 'refresh_token_request.g.dart';

@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  factory RefreshTokenRequest({required String userId, required String refreshToken}) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);

  @override
  String toString() => toJson().toString();
}
