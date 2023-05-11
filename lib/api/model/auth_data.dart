import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'auth_data.freezed.dart';
part 'auth_data.g.dart';
part 'auth_data.hive.dart';

@freezed
class AuthData with _$AuthData {
  const AuthData._();

  @HiveType(typeId: 5, adapterName: 'AuthDataAdapter')
  const factory AuthData({
    @HiveField(0) required String baseUrl,
    @HiveField(1) required String authUrl,
    @HiveField(2) required String tokenUrl,
  }) = _AuthData;

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);

  @override
  String toString() => toJson().toString();
}
