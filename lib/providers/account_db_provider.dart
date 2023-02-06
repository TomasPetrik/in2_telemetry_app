import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_data.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/care_plan/author.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/api/dto/user.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class AccountDbProvider extends BoxProvider<UserAccount> implements AccountDb {
  @override
  final String boxName = 'accountBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(UserAccountAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserPermissionAdapter());
    Hive.registerAdapter(AuthTokenAdapter());
    Hive.registerAdapter(HospitalAdapter());
    Hive.registerAdapter(AuthDataAdapter());
    Hive.registerAdapter(CarePlanAdapter());
    Hive.registerAdapter(CarePlanActivityAdapter());
    Hive.registerAdapter(AuthorAdapter());
    Hive.registerAdapter(ActivityTypeAdapter());
    Hive.registerAdapter(MeasurementTypeAdapter());
    Hive.registerAdapter(TimeUnitAdapter());
    Hive.registerAdapter(WeekDayAdapter());
    Hive.registerAdapter(TimingDayWhenAdapter());
    Hive.registerAdapter(TimingDayWhenTypeAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    Hive.registerAdapter(WhenCodeAdapter());
    Hive.registerAdapter(FulfillmentEvaluationAdapter());
    Hive.registerAdapter(FulfillmentEvaluationItemAdapter());
  }

  @override
  UserAccount? get(String id) {
    try {
      final rootAccounts = box.values;

      final List<UserAccount> allAccounts = [];

      for (final UserAccount localAccount in rootAccounts) {
        allAccounts.add(localAccount);
        if (localAccount.representedPeople?.isNotEmpty == true) {
          allAccounts.addAll(localAccount.representedPeople!);
        }
      }

      final UserAccount? local = allAccounts.firstWhereOrNull(
        (userAccountLocal) => userAccountLocal.user.muid == id,
      );

      return local;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserAccount> save(UserAccount userAccount) async {
    await box.put(
      userAccount.user.muid,
      userAccount,
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
      final rootAccounts = box.values.toList();

      final List<UserAccount> allAccounts = [];

      for (final UserAccount localAccount in rootAccounts) {
        allAccounts.add(localAccount);
        if (localAccount.representedPeople?.isNotEmpty == true) {
          allAccounts.addAll(localAccount.representedPeople!);
        }
      }

      final lastActiveAccounts = allAccounts
          .where(
            (account) => account.lastActiveIn != null,
          )
          .toList()
        ..sort(
          (a, b) => b.lastActiveIn!.millisecondsSinceEpoch
              .compareTo(a.lastActiveIn!.millisecondsSinceEpoch),
        );

      return lastActiveAccounts[0];
    } catch (_) {
      return null;
    }
  }

  @override
  Iterable<UserAccount> getAll() {
    return box.values;
  }

  List<UserAccount> getRootUsersFromHospital(Hospital hospital) {
    return box.values
        .where(
          (userAccountLocal) => userAccountLocal.hospital!.id == hospital.id,
        )
        .toList();
  }

  Map<Hospital, List<UserAccount>> getHospitalUsersMap() {
    final rootAccounts = box.values;

    final List<UserAccount> allAccounts = [];

    for (final UserAccount localAccount in rootAccounts) {
      allAccounts.add(localAccount);
      if (localAccount.representedPeople?.isNotEmpty == true) {
        allAccounts.addAll(localAccount.representedPeople!);
      }
    }

    return allAccounts
        .groupListsBy<Hospital>((userAccount) => userAccount.hospital!);
  }

  Future<UserAccount?> setExpiredUserByToken(String refreshToken) async {
    final rootAccounts = box.values.toList();

    final expiredAccount = rootAccounts.firstWhereOrNull(
      (userAccount) => userAccount.authToken?.refreshToken == refreshToken,
    );

    if (expiredAccount != null) {
      expiredAccount.sessionExpired = true;
      await box.put(
        expiredAccount.user.muid,
        expiredAccount,
      );
    }

    return expiredAccount;
  }

  bool isAnyAccountExpired() {
    final rootAccounts = box.values.toList();

    if (rootAccounts.any((userAccount) => userAccount.sessionExpired == true)) {
      return true;
    }

    return false;
  }
}

abstract class AccountDb {
  UserAccount? get(String id);
  Future<UserAccount> save(UserAccount account);
  Future<UserAccount> remove(UserAccount account);
  UserAccount? getLast();
  Iterable<UserAccount> getAll();
}
