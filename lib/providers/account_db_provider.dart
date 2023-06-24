import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/api/model/care_plan/author.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/care_plan/when_time_value.dart';
import 'package:scalesoft_app/api/model/device_model.dart';
import 'package:scalesoft_app/api/model/device_to_register.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/api/model/measurement_thresholds.dart';
import 'package:scalesoft_app/api/model/settings/time_setting.dart';
import 'package:scalesoft_app/api/model/template_time_set.dart';
import 'package:scalesoft_app/api/model/thresholds/blood_pressure_threshold_setting.dart';
import 'package:scalesoft_app/api/model/thresholds/heart_rate_threshold_setting.dart';
import 'package:scalesoft_app/api/model/thresholds/oxygen_saturation_threshold_setting.dart';
import 'package:scalesoft_app/api/model/thresholds/temperature_threshold_settings.dart';
import 'package:scalesoft_app/api/model/user.dart';
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
    Hive.registerAdapter(CarePlanVersionAdapter());
    Hive.registerAdapter(CarePlanActivityAdapter());
    Hive.registerAdapter(AuthorAdapter());
    Hive.registerAdapter(ActivityTypeAdapter());
    Hive.registerAdapter(MeasurementTypeAdapter());
    Hive.registerAdapter(TimeUnitAdapter());
    Hive.registerAdapter(WeekDayAdapter());
    Hive.registerAdapter(TimingDayWhenAdapter());
    Hive.registerAdapter(TimingDayWhenTypeAdapter());
    Hive.registerAdapter(DailyTimeAdapter());
    Hive.registerAdapter(WhenCodeAdapter());
    Hive.registerAdapter(FulfillmentEvaluationAdapter());
    Hive.registerAdapter(FulfillmentEvaluationItemAdapter());
    Hive.registerAdapter(FulfillmentEvaluationAggregatedAdapter());
    Hive.registerAdapter(MeasurementResultAdapter());
    Hive.registerAdapter(ComposedDoubleValueAdapter());
    Hive.registerAdapter(DeviceAdapter());
    Hive.registerAdapter(TemplateTimeSetAdapter());
    Hive.registerAdapter(WhenTimeValueAdapter());
    Hive.registerAdapter(TimeSettingAdapter());
    Hive.registerAdapter(DeviceModelAdapter());
    Hive.registerAdapter(DeviceToRegisterAdapter());
    Hive.registerAdapter(MeasurementThresholdsAdapter());
    Hive.registerAdapter(BloodPressureThresholdSettingAdapter());
    Hive.registerAdapter(HeartRateThresholdSettingAdapter());
    Hive.registerAdapter(OxygenSaturationThresholdSettingAdapter());
    Hive.registerAdapter(TemperatureThresholdSettingAdapter());
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

  UserAccount? getByToken(String accessToken) {
    try {
      final rootAccounts = box.values;
      final UserAccount? local = rootAccounts.firstWhereOrNull(
        (userAccountLocal) =>
            userAccountLocal.authToken?.accessToken == accessToken,
      );

      return local;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserAccount> save(UserAccount userAccount) async {
    if (userAccount.parentId != null) {
      final parentAccount = get(userAccount.parentId!)!;
      parentAccount.representedPeople?.removeWhere(
        (representedPerson) =>
            representedPerson.user.muid == userAccount.user.muid,
      );
      parentAccount.representedPeople?.add(userAccount);
      await box.put(
        parentAccount.user.muid,
        parentAccount,
      );
    } else {
      await box.put(
        userAccount.user.muid,
        userAccount,
      );
    }
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
          (a, b) => a.lastActiveIn!.millisecondsSinceEpoch
              .compareTo(b.lastActiveIn!.millisecondsSinceEpoch),
        );

      return lastActiveAccounts.last;
    } catch (_) {
      return null;
    }
  }

  @override
  Iterable<UserAccount> getRootAccounts() {
    return box.values;
  }

  @override
  List<UserAccount> getAll() {
    final allAccounts = box.values.fold<List<UserAccount>>(
      [],
      (prevAccounts, rootAccount) => [
        ...prevAccounts,
        rootAccount,
        if (rootAccount.representedPeople != null)
          ...rootAccount.representedPeople!
      ],
    );

    return allAccounts;
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

  CarePlan? getCarePlan(int carePlanId) {
    final rootAccounts = box.values.toList();

    for (final rootAccount in rootAccounts) {
      final carePlan = rootAccount.carePlans
          ?.firstWhereOrNull((carePlan) => carePlan.id == carePlanId);
      if (carePlan != null) {
        return carePlan;
      }

      for (final representedPerson in rootAccount.representedPeople!) {
        final carePlan = representedPerson.carePlans
            ?.firstWhereOrNull((carePlan) => carePlan.id == carePlanId);
        if (carePlan != null) {
          return carePlan;
        }
      }
    }

    return null;
  }

  List<CarePlan> getCarePlans(List<int> carePlansIds) {
    List<CarePlan> carePlans = [];
    final rootAccounts = box.values.toList();
    for (final rootAccount in rootAccounts) {
      final foundPlans = rootAccount.carePlans
          ?.where((carePlan) => carePlansIds.contains(carePlan.id));
      if (foundPlans?.isNotEmpty == true) {
        carePlans.addAll(foundPlans!);
      }

      for (final representedPerson in rootAccount.representedPeople!) {
        final foundPlans = representedPerson.carePlans?.where(
          (carePlan) => carePlansIds.contains(carePlan.id),
        );
        if (foundPlans?.isNotEmpty == true) {
          carePlans.addAll(foundPlans!);
        }
      }
    }
    return carePlans;
  }

  bool isAnyAccountExpired() {
    final rootAccounts = box.values.toList();

    if (rootAccounts.any((userAccount) => userAccount.sessionExpired == true)) {
      return true;
    }

    return false;
  }

  UserAccount? getFirstExpiredAccount() {
    final rootAccounts = box.values.toList();

    return rootAccounts
        .firstWhereOrNull((userAccount) => userAccount.sessionExpired == true);
  }
}

abstract class AccountDb {
  UserAccount? get(String id);
  Future<UserAccount> save(UserAccount account);
  Future<UserAccount> remove(UserAccount account);
  UserAccount? getLast();
  Iterable<UserAccount> getRootAccounts();
  Iterable<UserAccount> getAll();
}
