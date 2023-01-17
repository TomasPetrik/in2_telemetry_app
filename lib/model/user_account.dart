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
    DateTime? lastActiveIn,
    List<UserAccount>? representedPeople,
    bool? hasParent, 
    //TODO.. add care plan
  }) = _UserAccount;

  factory UserAccount.fromJson(Map<String, dynamic> json) =>
      _$UserAccountFromJson(json);

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
  final List<String>? phoneNumbers;

  @HiveField(4)
  final List<String>? emailAddresses;

  @HiveField(5)
  final AuthTokenLocal authTokenLocal;

  @HiveField(6)
  final HospitalLocal hospitalLocal;

  @HiveField(7)
  final DateTime signedIn;

  @HiveField(8)
  final DateTime? lastActiveIn;

  @HiveField(9)
  final List<UserAccountLocal>? representedPeople;

  @HiveField(11)
  bool? hasParent;

  UserAccountLocal({
    required this.muid,
    required this.firstNames,
    required this.lastNames,
    this.phoneNumbers,
    this.emailAddresses,
    required this.authTokenLocal,
    required this.hospitalLocal,
    required this.signedIn,
    this.lastActiveIn,
    this.representedPeople,
    this.hasParent,
  });
}
