import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';

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

@HiveType(typeId: 8)
class HiveEnum extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  HiveEnum({
    required this.key,
  });
}
