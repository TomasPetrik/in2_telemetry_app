import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const  User._();

  factory User(
    String muid,
    List<String> firstNames,
    List<String> lastNames,
  ) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  String toString() => toJson().toString();

  String get fullName => '${firstNames[0]} ${lastNames[0]}';
}
