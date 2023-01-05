import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/api/dto/user.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class AccountDbProvider extends BoxProvider<UserAccountLocal> implements AccountDb {
  @override
  final String boxName = 'accountBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(UserAccountLocalAdapter());
    Hive.registerAdapter(AuthTokenLocalAdapter());
    Hive.registerAdapter(HospitalLocalAdapter());
  }

  @override
  UserAccount? get(String id) {
    try {
      final UserAccountLocal? local = box.get(id);

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
        (acc, curr) => acc.signedIn.isAfter(curr.signedIn) ? acc : curr,
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

  Map<Hospital, List<UserAccount>> getHospitalUsers() {
    return box.values
        .map(
          _mapAccountFrom,
        )
        .groupListsBy<Hospital>((userAccount) => userAccount.hospital!);
  }
}

UserAccountLocal _mapAccountTo(UserAccount userAccount) {
  return UserAccountLocal(
    muid: userAccount.user.muid,
    firstNames: userAccount.user.firstNames,
    lastNames: userAccount.user.lastNames,
    authTokenLocal: AuthTokenLocal(
      accessToken: userAccount.authToken!.accessToken,
      refreshToken: userAccount.authToken!.refreshToken,
      expiresIn: userAccount.authToken!.accessTokenExpires,
    ),
    hospitalLocal: HospitalLocal(
      id: userAccount.hospital!.id,
      title: userAccount.hospital!.title,
      iconPath: userAccount.hospital!.iconPath,
    ),
    signedIn: userAccount.signedIn!,
  );
}

UserAccount _mapAccountFrom(UserAccountLocal localAccount) {
  return UserAccount(
    user: User(localAccount.muid, localAccount.firstNames, localAccount.lastNames),
    hospital: Hospital(
      id: localAccount.hospitalLocal.id,
      title: localAccount.hospitalLocal.title,
      iconPath: localAccount.hospitalLocal.iconPath,
    ),
    signedIn: localAccount.signedIn,
    authToken: AuthToken(
      accessToken: localAccount.authTokenLocal.accessToken,
      refreshToken: localAccount.authTokenLocal.refreshToken,
      accessTokenExpires: localAccount.authTokenLocal.expiresIn,
    ),
  );
}

abstract class AccountDb {
  UserAccount? get(String id);
  Future<UserAccount> save(UserAccount account);
  Future<UserAccount> remove(UserAccount account);
  UserAccount? getLast();
  Iterable<UserAccount> getAll();
}
