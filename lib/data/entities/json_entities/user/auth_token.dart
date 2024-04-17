import 'package:json_annotation/json_annotation.dart';
import 'package:drift/drift.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'auth_token.g.dart';

@JsonSerializable()
class AuthToken {
  String accessToken;
  String refreshToken;
  DateTime expires;

  AuthToken(this.accessToken, this.refreshToken, this.expires);

  factory AuthToken.fromJson(Map<String, dynamic> json) => _$AuthTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenToJson(this);

  static TypeConverter<AuthToken, String> converter = TypeConverter.json(
    fromJson: (json) => AuthToken.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  bool isExpiring(){
    return DateTime.now().add(const Duration(minutes: 5)).isAfterOrAt(expires);
  }
}
