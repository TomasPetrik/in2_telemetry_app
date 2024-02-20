import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation_aggregated.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/repositories/device_repository.dart';
import 'package:scalesoft_app/repositories/time_settings_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/notifications_helper.dart';

@singleton
class SyncService {
  final Session _session;
  final AccountDbProvider _accountDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final AccountRepository _accountRepository;
  final CarePlansRepository _carePlansRepository;
  final TimeSettingsRepository _timeSettingsRepository;
  final AppSettingsDbProvider _appSettingsDbProvider;
  final DeviceRepository _deviceRepository;

  SyncService(
    this._session,
    this._accountDbProvider,
    this._pendingResultsDbProvider,
    this._accountRepository,
    this._carePlansRepository,
    this._timeSettingsRepository,
    this._appSettingsDbProvider,
    this._deviceRepository,
  );

  Future<void> setUserPlans(
    final UserAccount userAccount,
    final List<CarePlan> newCarePlans,
  ) async {
    for (final carePlan in newCarePlans) {
      carePlan.userId = userAccount.user.muid;
    }

    final currentCarePlans = userAccount.carePlans;
    //check if plans were updated
    if (currentCarePlans != null) {
      for (final newCarePlan in newCarePlans) {
        final currentPlan = currentCarePlans.firstWhereOrNull(
          (currentCarePlan) => currentCarePlan.id == newCarePlan.id,
        );

        if (currentPlan != null) {
          if (newCarePlan.versionId > currentPlan.versionId) {
            newCarePlan.wasChanged = true;
          } else {
            newCarePlan.wasChanged = currentPlan.wasChanged;
          }
        }

        //also load all versions for carePlan
        final carePlanVersions = await _carePlansRepository.loadCarePlanVersions(
          userAccount: userAccount,
          carePlan: newCarePlan,
        );
        newCarePlan.carePlanVersions = carePlanVersions.items;
      }
    }

    userAccount.carePlans = newCarePlans;
  }

  Future<void> loadWhenValues(final UserAccount userAccount) async {
    final whenTimeValuesResponse = await _timeSettingsRepository.loadPlanTemplate(userAccount: userAccount);
    userAccount.templateTimeSet = whenTimeValuesResponse;
    for (final UserAccount representedPerson in userAccount.representedPeople!) {
      representedPerson.templateTimeSet = whenTimeValuesResponse;
    }
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

  Future<void> loadDeviceModels(final UserAccount userAccount) async {
    try {
      final deviceModels = await _deviceRepository.getDeviceModels(
        userAccount: userAccount,
      );
      userAccount.supportedDeviceModels = deviceModels;
      for (final UserAccount representedPerson in userAccount.representedPeople!) {
        representedPerson.supportedDeviceModels = deviceModels;
      }
    } on Exception {
      debugPrint(
        'Couln\'t load device models for user ${userAccount.user.fullName}',
      );
    }
  }

  Future<void> loadUserData(final UserAccount userAccount) async {
    //load active care plans, fulfillment_evaluation, results
    final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
      userAccount: userAccount,
    );

    setUserPlans(userAccount, activeCarePlans.items);

    //check and update assigned devices, current user data and his represented people
    //await checkForDataChanges(userAccount);

    await loadFulFillmentEvaluation(userAccount);
    await loadPartPlanEvaluation(userAccount);
    if (userAccount.viewOwnMeasurementData) {
      await loadMeasurementResults(userAccount);
    }

    userAccount.carePlans = activeCarePlans.items;
    if (userAccount.representedPeople?.isNotEmpty == true) {
      for (final UserAccount representedPerson in userAccount.representedPeople!) {
        final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
          userAccount: representedPerson,
        );

        setUserPlans(representedPerson, activeCarePlans.items);

        for (final carePlan in activeCarePlans.items) {
          carePlan.userId = representedPerson.user.muid;
        }

        representedPerson.carePlans = activeCarePlans.items;

        await loadPartPlanEvaluation(representedPerson);

        if (userAccount.viewOwnMeasurementData) {
          await loadMeasurementResults(representedPerson);
        }
      }
    }
  }

  Future<void> removeOfflineResult(MeasurementResult measurementResult) async {
    await _pendingResultsDbProvider.removeByDateTime(measurementResult.measurementDateTime);
  }

  Future<void> updateUserData(UserAccount userAccount) async {
    //check changes for root user and his represented people

    //update only root users but not representing people specifically
    if (!userAccount.isParentAccount) return;

    final userInfo = await _accountRepository.loadUserInfo(
      authToken: userAccount.authToken!,
      apiUrl: userAccount.hospital!.authData.baseUrl,
    );

    //1. Update assigned devices
    userAccount.assignedDevices = parseAssignedDevices(userInfo.assignedDevices, userAccount.assignedDevices);
    getIt<BackgroundMeasurementManager>().removeUnassignedDevices();

    userAccount.user = userInfo.currentUser;
  }

  List<Device>? parseAssignedDevices(List<Device>? devices, List<Device>? originalDevices) {
    if (devices == null) {
      return null;
    }

    final List<Device> result = [];

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
        carePlan.fullPlanEvaluation = FulfillmentEvaluationAggregated(
          DateTime.now(),
          DateTime.now(),
          0,
          0,
          0,
        );
      }
    }
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
  }

  /* load today's and yesterday's measurement results */
  Future<void> loadMeasurementResults(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) return;

    var supportedMeasurementTypes = (userAccount.carePlans?.map((x) => x.activity.measurementType) ?? []).toSet();

    if (userAccount.hospital != null) {
      supportedMeasurementTypes.addAll(userAccount.hospital!.enabledMeasurementTypes);
    } else {
      supportedMeasurementTypes.addAll(ConfigurationConstants.supportedMeasurementTypes);
    }

    final yesterdayMidnight = DateTime.now().yesterday;
    final tomorrowMidnight = DateTime.now().tomorrow;

    final List<MeasurementResult> allResults = [];
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
    final userAccounts = syncAllUsers ? _accountDbProvider.getAll().toList() : _session.getSessionAccounts();

    for (final UserAccount userAccount in userAccounts) {
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
    final Set<String> allowedUsersMuids =
        _session.getSessionAccounts().map((userAccount) => userAccount.user.muid).toSet();

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
        //TODO.. here is gap when we should wait until backend will udpate date in their dbs
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
