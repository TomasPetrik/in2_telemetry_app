import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._();

  @HiveType(typeId: 3, adapterName: 'UserAdapter')
  factory User({
    @HiveField(1) required String muid,
    @HiveField(2) required List<String> firstNames,
    @HiveField(3) required List<String> lastNames,
    @HiveField(4) List<String>? phoneNumbers,
    @HiveField(5) List<String>? emailAddresses,
    @HiveField(6) List<User>? representedPeople,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  String toString() => toJson().toString();

  String get fullName => '${firstNames[0]} ${lastNames[0]}';
}
