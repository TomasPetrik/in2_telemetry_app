import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'auth_data.freezed.dart';
part 'auth_data.g.dart';

@freezed
class AuthData with _$AuthData {
  const AuthData._();

  const factory AuthData({
    required String baseUrl,
    required String authUrl,
    required String tokenUrl,
  }) = _AuthData;

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 5)
class AuthDataLocal extends HiveObject {
  @HiveField(0)
  final String baseUrl;

  @HiveField(1)
  final String authUrl;

  @HiveField(2)
  final String tokenUrl;

  AuthDataLocal({
    required this.baseUrl,
    required this.authUrl,
    required this.tokenUrl,
  });
}
