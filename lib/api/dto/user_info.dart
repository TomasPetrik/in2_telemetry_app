import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/user.dart';

part 'user_info.freezed.dart';
part 'user_info.g.dart';

@freezed
class UserInfo with _$UserInfo {
  const UserInfo._();

  const factory UserInfo(User currentUser) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  @override
  String toString() => toJson().toString();
}
