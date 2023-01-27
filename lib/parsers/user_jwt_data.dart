import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'user_jwt_data.freezed.dart';
part 'user_jwt_data.g.dart';

@freezed
class UserJwtData with _$UserJwtData {
  factory UserJwtData(
    List<UserPermission> permission,
  ) = _UserPermissions;

  factory UserJwtData.fromJson(Map<String, dynamic> json) =>
      _$UserJwtDataFromJson(json);

  @override
  String toString() => toJson().toString();
}
