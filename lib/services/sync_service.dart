import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/model/care_plan_create_model.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/repositories/device_repository.dart';
import 'package:scalesoft_app/repositories/time_settings_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

@singleton
class SyncService {
  final UserCubit _session;
  final AccountRepository _accountRepository;
  final CarePlansRepository _carePlansRepository;
  final TimeSettingsRepository _timeSettingsRepository;
  final DeviceRepository _deviceRepository;
  final CarePlanDbProvider _carePlanDbProvider;

  SyncService(
    this._session,
    this._accountRepository,
    this._carePlansRepository,
    this._timeSettingsRepository,
    this._deviceRepository,
    this._carePlanDbProvider,
  );

  Future<void> setUserPlans(
    final int userid,
    final List<CarePlanContract> newCarePlans,
  ) async {
    final currentCarePlans = await _carePlanDbProvider.getByUser(userid);

    final yesterdayMidnight = DateTime.now().yesterday;
    var tomorrowMidnight = DateTime.now().tomorrow;

    final List<CarePlanCreateModel> results = [];

    for (final newCarePlan in newCarePlans) {
      final currentPlan = currentCarePlans.firstWhereOrNull(
        (currentCarePlan) => currentCarePlan.id == newCarePlan.id,
      );

      var wasChanged = false;

      // check if plans were updated
      if (currentPlan != null) {
        final currentVersion = currentPlan.versions.map((x) => x.versionId).max;
        wasChanged = newCarePlan.versionId > currentVersion;
      }

      //also load all versions for carePlan
      final carePlanVersions = await _carePlansRepository.loadCarePlanVersions(
        userId: userid,
        carePlanId: newCarePlan.id,
      );

      // TODO: Maybe load evaluation of the whole plan, not just the latest version?
      final fullPlanEvaluation = await _carePlansRepository.loadFullPlanEvaluation(
        userId: userid,
        carePlanVersionId: newCarePlan.versionId,
      );

      List<FulfillmentEvaluationItem> evaluationItems = [];

      if (newCarePlan.scheduledEnd?.isBefore(yesterdayMidnight) == true ||
          newCarePlan.scheduledStart.isAfter(tomorrowMidnight)) {
        debugPrint(
          'not loading evaluation items for planId = ${newCarePlan.id}',
        );
      } else {
        DateTime from = yesterdayMidnight;
        if (newCarePlan.scheduledStart.isAfter(yesterdayMidnight)) {
          from = newCarePlan.scheduledStart;
        }

        DateTime to = tomorrowMidnight;
        if (newCarePlan.scheduledEnd?.isBefore(tomorrowMidnight) == true) {
          to = newCarePlan.scheduledEnd!;
        }

        from = from.toUtc();
        to = to.toUtc();

        evaluationItems = await _carePlansRepository.loadPartPlanEvaluation(
          userId: userid,
          carePlanId: newCarePlan.id,
          fromDateTime: from.toIso8601String(),
          toDateTime: to.toIso8601String(),
        );
      }

      results.add(
          CarePlanCreateModel(newCarePlan, wasChanged, carePlanVersions.items, fullPlanEvaluation, evaluationItems),);
    }

    await _carePlanDbProvider.replaceUserCarePlans(userid, results);
  }

  Future<void> loadTimeSettings(final UserAccount userAccount) async {
    final timeSettingItems = await _timeSettingsRepository.loadTimeSettings(
      userAccount: userAccount,
    );
    userAccount.timeSettingItems = timeSettingItems;
    for (final UserAccount representedPerson in userAccount.representedPeople!) {
      representedPerson.timeSettingItems = timeSettingItems;
    }
  }

  Future<void> loadDeviceModels(final int userId) async {
    try {
      final deviceModels = await _deviceRepository.getDeviceModels(
        userId: userId,
      );
      userAccount.supportedDeviceModels = deviceModels;
      for (final UserAccount representedPerson in userAccount.representedPeople!) {
        representedPerson.supportedDeviceModels = deviceModels;
      }
    } on Exception {
      debugPrint(
        'Couln\'t load device models for user $userId',
      );
    }
  }

  Future<void> loadUserData(final int userId) async {
    final user = _session.state.rootUsers.firstWhere((x) => x.id == userId);

    //load active care plans, fulfillment_evaluation, results
    final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
      userId: userId,
    );

    await setUserPlans(userId, activeCarePlans.items);

    //check and update assigned devices, current user data and his represented people
    //await checkForDataChanges(userAccount);

    await loadFulFillmentEvaluation(userAccount);
    await loadPartPlanEvaluation(userAccount);
    if (userAccount.viewOwnMeasurementData) {
      await loadMeasurementResults(userAccount);
    }

    if (user.representedPeople.isNotEmpty) {
      for (final representedPerson in user.representedPeople) {
        final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
          userId: representedPerson.id,
        );

        await setUserPlans(representedPerson.id, activeCarePlans.items);

        representedPerson.carePlans = activeCarePlans.items;

        await loadPartPlanEvaluation(representedPerson);

        if (userAccount.viewOwnMeasurementData) {
          await loadMeasurementResults(representedPerson);
        }
      }
    }
  }

  Future<void> removeOfflineResult(MeasurementDataContract measurementResult) async {
    await _pendingResultsDbProvider
        .removeByDateTime(measurementResult.measurementDateTime);
  }

  Future<void> updateUserData(UserModel userAccount) async {
    //check changes for root user and his represented people

    //update only root users but not representing people specifically
    if (userAccount.isRepresentedPerson) return;

    final userInfo = await _accountRepository.loadUserInfo(
      authToken: userAccount.authToken,
      apiUrl: userAccount.hospital.authData.baseUrl,
    );

    //1. Update assigned devices
    // userAccount.assignedDevices = parseAssignedDevices(userInfo.assignedDevices, userAccount.assignedDevices);
    getIt<BackgroundMeasurementManager>().removeUnassignedDevices();

    // userAccount.user = userInfo.currentUser;
  }

  List<SourceDeviceContract>? parseAssignedDevices(
      List<SourceDeviceContract>? devices, List<SourceDeviceContract>? originalDevices,) {
    if (devices == null) {
      return null;
    }

    final List<SourceDeviceContract> result = [];

    for (final device in devices) {
      final devicePrototype = ConfigurationConstants.supportedDevices.firstWhereOrNull(
        (suppDev) => suppDev.modelName == device.modelName && suppDev.deviceManufacturer == device.deviceManufacturer,
      );

      if (devicePrototype == null) continue;

      final existingDevice = originalDevices?.firstWhereOrNull((x) => x.isEquivalentTo(device));

      result.add(
        devicePrototype.copyWith(
          deviceIdentifier: device.deviceIdentifier,
          assignedIdentifier: device.assignedIdentifier,
          bluetoothAddress: device.bluetoothAddress,
          isLendedDevice: true,
          lastMeasurementTime: existingDevice?.lastMeasurementTime,
        ),
      );
    }

    return result;
  }

  Future<void> loadFulFillmentEvaluation(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) {
      return;
    }

    for (final carePlan in carePlans) {
      try {
        final fullPlanEvaluation = await _carePlansRepository.loadFullPlanEvaluation(
          userAccount: userAccount,
          carePlanVersionId: carePlan.versionId,
        );
        carePlan.fullPlanEvaluation = fullPlanEvaluation;
      } catch (e) {
        carePlan.fullPlanEvaluation = AggregatedFulfillmentEvaluationContract(
          DateTime.now(),
          DateTime.now(),
          0,
          0,
          0,
        );
      }
    }
    userAccount.carePlans = carePlans;
  }

  Future<void> loadPartPlanEvaluation(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) {
      return;
    }

    final yesterdayMidnight = DateTime.now().yesterday;
    var tomorrowMidnight = DateTime.now().tomorrow;

    for (final carePlan in carePlans) {
      if (carePlan.scheduledEnd?.isBefore(yesterdayMidnight) == true ||
          carePlan.scheduledStart.isAfter(tomorrowMidnight)) {
        debugPrint(
          'skipping load last two days evaluation for planId = ${carePlan.id}',
        );
        continue;
      }

      DateTime from = yesterdayMidnight;
      if (carePlan.scheduledStart.isAfter(yesterdayMidnight)) {
        from = carePlan.scheduledStart;
      }

      DateTime to = tomorrowMidnight;
      if (carePlan.scheduledEnd?.isBefore(tomorrowMidnight) == true) {
        to = carePlan.scheduledEnd!;
      }

      from = from.toUtc();
      to = to.toUtc();

      final lastTwoDaysEvaluation = await _carePlansRepository.loadPartPlanEvaluation(
        userAccount: userAccount,
        carePlanId: carePlan.id,
        fromDateTime: from.toIso8601String(),
        toDateTime: to.toIso8601String(),
      );
      carePlan.serverEvaluationItems = lastTwoDaysEvaluation.items;
    }

    userAccount.carePlans = carePlans;
  }

  /* load today's and yesterday's measurement results */
  Future<void> loadMeasurementResults(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) return;

    var supportedMeasurementTypes = (userAccount.carePlans?.map((x) => x.activity.measurementType) ?? []).toSet();

    if (userAccount.hospital != null) {
      supportedMeasurementTypes
          .addAll(userAccount.hospital!.enabledMeasurementTypes);
    }

    final yesterdayMidnight = DateTime.now().yesterday;
    final tomorrowMidnight = DateTime.now().tomorrow;

    final List<MeasurementDataContract> allResults = [];
    for (final measurementType in supportedMeasurementTypes) {
      final measurementResults = await _carePlansRepository.loadResults(
        userAccount: userAccount,
        measurementType: measurementType,
        startDateTime: yesterdayMidnight.toIso8601String(),
        endDateTime: tomorrowMidnight.toIso8601String(),
      );
      allResults.addAll(measurementResults);
    }
    userAccount.measurementResults = allResults;
  }

  Future<void> syncAllData({bool syncAllUsers = false}) async {
    final users = syncAllUsers ? _session.state.rootUsers : [_session.state.currentUser];

    for (final user in users) {
      try {
        await loadUserData(userAccount);
        userAccount.lastSyncAt = DateTime.now();
        userAccount.lastSyncFailed = false;
        await updateUserData(userAccount);
        await _accountDbProvider.save(userAccount);
      } on DioException {
        //for any failed sync set flag and go on next account
        userAccount.lastSyncFailed = true;
        await _accountDbProvider.save(userAccount);
        //return;
      }
    }
    NotificationsHelper.setNotifications(
      appSettings: _appSettingsDbProvider.read(),
      notificationsPlugin: FlutterLocalNotificationsPlugin(),
      userAccounts: _accountDbProvider.getAll(),
    );
  }

  Future<void> syncResults() async {
    final users = _session.state.rootUsers;

    for (final userId in allowedUsersMuids) {
      final userAccount = _accountDbProvider.get(userId);
      if (userAccount == null) {
        _pendingResultsDbProvider.removeUserResults(userId);
        continue;
      }

      try {
        final userMeasurements = _pendingResultsDbProvider.getPerUser(userId);
        if (userMeasurements.isEmpty) {
          continue;
        }

        for (final userMeasurement in userMeasurements) {
          if (userMeasurement.sourceDeviceWithMetadata != null) {
            await _carePlansRepository.sendMeasurementFromDevice(
              userAccount: userAccount,
              measurement: userMeasurement,
            );
          } else {
            await _carePlansRepository.sendManualMeasurement(
              userAccount: userAccount,
              manualMeasurement: userMeasurement,
            );
          }
          await _pendingResultsDbProvider.remove(userMeasurement);
        }
        //TODO.. here is gap when we should wait until backend will update date in their dbs
        await Future.delayed(const Duration(seconds: 3));
        //reload user results
        await loadFulFillmentEvaluation(userAccount);
        await loadPartPlanEvaluation(userAccount);
        if (userAccount.viewOwnMeasurementData) {
          await loadMeasurementResults(userAccount);
        }
        userAccount.lastSyncAt = DateTime.now();
        userAccount.lastSyncFailed = false;
        await _accountDbProvider.save(userAccount);
      } catch (e) {
        //for any failed sync set flag
        userAccount.lastSyncFailed = true;
        await _accountDbProvider.save(userAccount);
        return;
      }
    }
  }
}
