import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_jwt_data.g.dart';

@JsonSerializable()
class UserJwtData {
  @JsonKey(name: "permission")
  final List<String> permissions;

  const UserJwtData({
    required this.permissions,
  });

  factory UserJwtData.fromJson(Map<String, dynamic> json) => _$UserJwtDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserJwtDataToJson(this);

  @override
  String toString() => toJson().toString();
}
