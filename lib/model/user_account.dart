import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/api/dto/user.dart';

part 'user_account.freezed.dart';
part 'user_account.g.dart';

@freezed
class UserAccount with _$UserAccount {
  const UserAccount._();

  factory UserAccount({
    required User user,
    AuthToken? authToken,
    Hospital? hospital,
    DateTime? signedIn,
  }) = _UserAccount;

  factory UserAccount.fromJson(Map<String, dynamic> json) => _$UserAccountFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 2)
class UserAccountLocal extends HiveObject {
  @HiveField(0)
  final String muid;

  @HiveField(1)
  final List<String> firstNames;

  @HiveField(2)
  final List<String> lastNames;

  @HiveField(3)
  final AuthTokenLocal authTokenLocal;

  @HiveField(4)
  final HospitalLocal hospitalLocal;

  @HiveField(5)
  final DateTime signedIn;

  UserAccountLocal({
    required this.muid,
    required this.firstNames,
    required this.lastNames,
    required this.authTokenLocal,
    required this.hospitalLocal,
    required this.signedIn,
  });
}
