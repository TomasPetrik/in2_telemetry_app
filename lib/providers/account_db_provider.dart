import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_data.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/care_plan/author.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/api/dto/user.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';
import 'package:scalesoft_app/parsers/user_jwt_data.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class AccountDbProvider extends BoxProvider<UserAccountLocal>
    implements AccountDb {
  @override
  final String boxName = 'accountBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(UserAccountLocalAdapter());
    Hive.registerAdapter(AuthTokenLocalAdapter());
    Hive.registerAdapter(HospitalLocalAdapter());
    Hive.registerAdapter(AuthDataLocalAdapter());
    Hive.registerAdapter(HiveEnumAdapter());
    Hive.registerAdapter(CarePlanAdapter());
    Hive.registerAdapter(CarePlanActivityAdapter());
    Hive.registerAdapter(AuthorAdapter());
    Hive.registerAdapter(ActivityTypeAdapter());
    Hive.registerAdapter(MeasurementTypeAdapter());
    Hive.registerAdapter(TimeUnitEnumContractAdapter());
    Hive.registerAdapter(WeekDayEnumAppContractAdapter());
    Hive.registerAdapter(TimingDayWhenAdapter());
    Hive.registerAdapter(TimingDayWhenTypeAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    Hive.registerAdapter(WhenCodeAdapter());
  }

  @override
  UserAccount? get(String id) {
    try {
      final rootAccounts = box.values;

      final List<UserAccountLocal> allAccounts = [];

      for (final UserAccountLocal localAccount in rootAccounts) {
        allAccounts.add(localAccount);
        if (localAccount.representedPeople?.isNotEmpty == true) {
          allAccounts.addAll(localAccount.representedPeople!);
        }
      }

      final UserAccountLocal? local = allAccounts.firstWhereOrNull(
        (userAccountLocal) => userAccountLocal.muid == id,
      );

      return local != null ? _mapAccountFrom(local) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserAccount> save(UserAccount userAccount) async {
    await box.put(
      userAccount.user.muid,
      _mapAccountTo(userAccount),
    );
    return userAccount;
  }

  @override
  Future<UserAccount> remove(UserAccount userAccount) async {
    await box.delete(userAccount.user.muid);
    return userAccount;
  }

  @override
  UserAccount? getLast() {
    try {
      final localAccount = box.values.reduce(
        (acc, current) =>
            acc.signedIn.isAfter(current.signedIn) ? acc : current,
      );

      final isZero = localAccount.signedIn.isAtSameMomentAs(
        DateTime.fromMillisecondsSinceEpoch(0),
      );
      if (isZero) return null;

      return _mapAccountFrom(localAccount);
    } catch (_) {
      return null;
    }
  }

  @override
  Iterable<UserAccount> getAll() {
    return box.values.map(
      _mapAccountFrom,
    );
  }

  List<UserAccount> getRootUsersFromHospital(Hospital hospital) {
    final rootAccounts = box.values.where(
      (userAccountLocal) => userAccountLocal.hospitalLocal.id == hospital.id,
    );

    return rootAccounts.map(_mapAccountFrom).toList();
  }

  Map<Hospital, List<UserAccount>> getHospitalUsersMap() {
    final rootAccounts = box.values;

    final List<UserAccountLocal> allAccounts = [];

    for (final UserAccountLocal localAccount in rootAccounts) {
      allAccounts.add(localAccount);
      if (localAccount.representedPeople?.isNotEmpty == true) {
        allAccounts.addAll(localAccount.representedPeople!);
      }
    }

    return allAccounts
        .map(
          _mapAccountFrom,
        )
        .groupListsBy<Hospital>((userAccount) => userAccount.hospital!);
  }

  UserAccountLocal _mapAccountTo(UserAccount userAccount) {
    return UserAccountLocal(
      muid: userAccount.user.muid,
      firstNames: userAccount.user.firstNames,
      lastNames: userAccount.user.lastNames,
      phoneNumbers: userAccount.user.phoneNumbers,
      emailAddresses: userAccount.user.emailAddresses,
      representedPeople: userAccount.representedPeople == null
          ? null
          : _mapAccountsTo(userAccount, userAccount.representedPeople!),
      authTokenLocal: AuthTokenLocal(
        accessToken: userAccount.authToken!.accessToken,
        refreshToken: userAccount.authToken!.refreshToken,
        expiresIn: userAccount.authToken!.accessTokenExpires,
      ),
      userPermissions: userAccount.userPermissions!
          .map((userPermission) => HiveEnum(key: userPermission.key))
          .toList(),
      hospitalLocal: HospitalLocal(
        id: userAccount.hospital!.id,
        title: userAccount.hospital!.title,
        iconPath: userAccount.hospital!.iconPath,
        authData: AuthDataLocal(
          baseUrl: userAccount.hospital!.authData.baseUrl,
          authUrl: userAccount.hospital!.authData.authUrl,
          tokenUrl: userAccount.hospital!.authData.tokenUrl,
        ),
      ),
      signedIn: userAccount.signedIn!,
      lastActiveIn: userAccount.lastActiveIn,
      hasParent: false,
      carePlans: userAccount.carePlans,
    );
  }

  List<UserAccountLocal> _mapAccountsTo(
    final UserAccount parentAccount,
    List<UserAccount> usersAccounts,
  ) {
    List<UserAccountLocal> representedPeopleLocal = [];

    for (final UserAccount userAccount in usersAccounts) {
      UserAccount childAccount = parentAccount.copyWith(
        user: userAccount.user,
        lastActiveIn: null,
        representedPeople: null,
        carePlans: userAccount.carePlans,
      );

      representedPeopleLocal.add(
        _mapAccountTo(childAccount)..hasParent = true,
      );
    }

    return representedPeopleLocal;
  }

  UserAccount _mapAccountFrom(UserAccountLocal localAccount) {
    return UserAccount(
      user: User(
        muid: localAccount.muid,
        firstNames: localAccount.firstNames,
        lastNames: localAccount.lastNames,
        phoneNumbers: localAccount.phoneNumbers,
        emailAddresses: localAccount.emailAddresses,
      ),
      hospital: Hospital(
        id: localAccount.hospitalLocal.id,
        title: localAccount.hospitalLocal.title,
        iconPath: localAccount.hospitalLocal.iconPath,
        authData: AuthData(
          baseUrl: localAccount.hospitalLocal.authData.baseUrl,
          authUrl: localAccount.hospitalLocal.authData.authUrl,
          tokenUrl: localAccount.hospitalLocal.authData.tokenUrl,
        ),
      ),
      signedIn: localAccount.signedIn,
      authToken: AuthToken(
        accessToken: localAccount.authTokenLocal.accessToken,
        refreshToken: localAccount.authTokenLocal.refreshToken,
        accessTokenExpires: localAccount.authTokenLocal.expiresIn,
      ),
      userPermissions: localAccount.userPermissions
          .map(
            (userPermissionLocal) => UserPermission.values.firstWhere(
              (userPermission) => userPermission.key == userPermissionLocal.key,
            ),
          )
          .toList(),
      representedPeople: localAccount.representedPeople == null
          ? null
          : _mapAccountsFrom(localAccount.representedPeople!),
      hasParent: localAccount.hasParent,
      carePlans: localAccount.carePlans,
    );
  }

  List<UserAccount> _mapAccountsFrom(
    List<UserAccountLocal> localUsers,
  ) {
    List<UserAccount> users = [];

    for (final UserAccountLocal localUser in localUsers) {
      users.add(_mapAccountFrom(localUser));
    }

    return users;
  }
}

abstract class AccountDb {
  UserAccount? get(String id);
  Future<UserAccount> save(UserAccount account);
  Future<UserAccount> remove(UserAccount account);
  UserAccount? getLast();
  Iterable<UserAccount> getAll();
}
