import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/measurement_thresholds.dart';

part 'user.freezed.dart';
part 'user.g.dart';
part 'user.hive.dart';

@freezed
class User with _$User {
  const User._();

  @HiveType(typeId: 3, adapterName: 'UserAdapter')
  factory User(
    @HiveField(1) String muid,
    @HiveField(2) List<String> firstNames,
    @HiveField(3) List<String> lastNames,
    @HiveField(4) List<String>? phoneNumbers,
    @HiveField(5) List<String>? emailAddresses,
    @HiveField(6) List<User>? representedPeople,
    @HiveField(7) MeasurementThresholds measurementThresholds,
  ) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  String toString() => toJson().toString();

  String get fullName => '${firstNames[0]} ${lastNames[0]}';
}
