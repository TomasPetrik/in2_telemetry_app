import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/manual_measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/data/providers/device_db_provider.dart';
import 'package:scalesoft_app/data/providers/device_prototype_db_provider.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/data/providers/when_template_db_provider.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';
import 'package:scalesoft_app/model/care_plan_create_model.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/repositories/device_repository.dart';
import 'package:scalesoft_app/repositories/time_settings_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/notifications_helper.dart';

@singleton
class SyncService {
  final UserCubit _session;
  final AccountRepository _accountRepository;
  final CarePlansRepository _carePlansRepository;
  final TimeSettingsRepository _timeSettingsRepository;
  final DeviceRepository _deviceRepository;
  final CarePlanDbProvider _carePlanDbProvider;
  final MeasurementTypeMapper _measurementTypeMapper;
  final MeasurementsDbProvider _measurementsDbProvider;
  final UserDbProvider _userDbProvider;
  final DevicePrototypeDbProvider _devicePrototypeDbProvider;
  final WhenTemplateDbProvider _whenTemplateDbProvider;
  final DeviceDbProvider _deviceDbProvider;
  final SettingsDbProvider _settingsDbProvider;

  SyncService(
    this._session,
    this._accountRepository,
    this._carePlansRepository,
    this._timeSettingsRepository,
    this._deviceRepository,
    this._carePlanDbProvider,
    this._measurementTypeMapper,
    this._measurementsDbProvider,
    this._userDbProvider,
    this._devicePrototypeDbProvider,
    this._whenTemplateDbProvider,
    this._deviceDbProvider,
    this._settingsDbProvider,
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
        CarePlanCreateModel(newCarePlan, wasChanged, carePlanVersions.items, fullPlanEvaluation, evaluationItems),
      );
    }

    await _carePlanDbProvider.replaceUserCarePlans(userid, results);
  }

  Future<void> loadWhenValues(final int userId) async {
    final user = _session.state.allUsers.firstWhere((x) => x.id == userId);

    final whenTimeValuesResponse = await _timeSettingsRepository.loadPlanTemplate(userId: userId);
    await _whenTemplateDbProvider.replaceUserTemplates(userId, whenTimeValuesResponse.whenTimeValues);

    for (final representedPerson in user.representedPeople) {
      await _whenTemplateDbProvider.replaceUserTemplates(representedPerson.id, whenTimeValuesResponse.whenTimeValues);
    }
  }

  Future<void> loadDeviceModels(final int userId) async {
    try {
      final user = _session.state.allUsers.firstWhere((x) => x.id == userId);

      final deviceModels = await _deviceRepository.getDeviceModels(
        userId: userId,
      );

      await _devicePrototypeDbProvider.replaceUserPrototypes(userId, deviceModels);

      for (final representedPerson in user.representedPeople) {
        await _devicePrototypeDbProvider.replaceUserPrototypes(representedPerson.id, deviceModels);
      }
    } on Exception {
      debugPrint(
        'Couln\'t load device models for user $userId',
      );
    }
  }

  Future<void> loadUserData(final int userId) async {
    final user = _session.state.allUsers.firstWhere((x) => x.id == userId);

    //load active care plans, fulfillment_evaluation, results
    final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
      userId: userId,
    );

    final plansOfUser = activeCarePlans.items.where((x) => x.targetUserMuid == user.muid).toList();

    await setUserPlans(userId, plansOfUser);

    //check and update assigned devices, current user data and his represented people
    //await checkForDataChanges(userAccount);

    if (user.permissions.any((x) => x == Permissions.viewOwnMeasurementData)) {
      await loadMeasurementResults(userId);
    }

    if (user.representedPeople.isNotEmpty) {
      for (final representedPerson in user.representedPeople) {
        final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
          userId: representedPerson.id,
        );

        final plansOfPerson = activeCarePlans.items.where((x) => x.targetUserMuid == representedPerson.muid).toList();

        await setUserPlans(representedPerson.id, plansOfPerson);

        if (representedPerson.permissions.any((x) => x == Permissions.viewOwnMeasurementData)) {
          await loadMeasurementResults(representedPerson.id);
        }
      }
    }
  }

  Future<void> removeOfflineResult(DateTime measurementTime, MeasurementType measurementType) async {
    await _measurementsDbProvider.removeOfflineMeasurement(measurementTime, measurementType);
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
    _deviceDbProvider.updateUserDevices(userAccount.id, userInfo.assignedDevices ?? []);
    getIt<BackgroundMeasurementManager>().removeUnassignedDevices();

    _userDbProvider.updateUserFromContract(userAccount.id, userInfo.currentUser);
  }

  /* load today's and yesterday's measurement results */
  Future<void> loadMeasurementResults(int userId) async {
    final carePlans = await _carePlanDbProvider.getByUser(userId);
    if (carePlans.isEmpty) {
      return;
    }

    final user = _session.state.allUsers.firstWhereOrNull((x) => x.id == userId);
    if (user == null) {
      return;
    }

    var supportedMeasurementTypes = carePlans.map((x) => x.activity.measurementType).toSet();

    supportedMeasurementTypes.addAll(user.hospital.enabledMeasurementTypes);

    final yesterdayMidnight = DateTime.now().yesterday;
    final tomorrowMidnight = DateTime.now().tomorrow;

    final List<MeasurementDataContract> allResults = [];
    for (final measurementType in supportedMeasurementTypes) {
      final MeasurementTypeContract measurementTypeContract = _measurementTypeMapper.convert(measurementType);

      final measurementResults = await _carePlansRepository.loadResults(
        userId: userId,
        measurementType: measurementTypeContract,
        startDateTime: yesterdayMidnight.toIso8601String(),
        endDateTime: tomorrowMidnight.toIso8601String(),
      );
      allResults.addAll(measurementResults);
    }

    await _measurementsDbProvider.saveAll(allResults, userId);
  }

  Future<void> syncAllData({bool syncAllUsers = false}) async {
    final users = syncAllUsers ? _session.state.rootUsers : [_session.state.currentUser];

    for (final user in users) {
      try {
        await updateUserData(user);

        await loadUserData(user.id);

        final now = DateTime.now();
        await _userDbProvider.updateUser(
          user.id,
          UsersCompanion(
            lastSyncAt: Value(now),
            lastSyncFailed: const Value(false),
            isSessionExpired: const Value(false),
          ),
        );

        await _session.waitForChange((x) => x.id == user.id && x.lastSyncAt.isAtSameMomentAs(now));
      } on DioException {
        //for any failed sync set flag and go on next account
        await _userDbProvider.updateUser(user.id, const UsersCompanion(lastSyncFailed: Value(true)));
      }
    }

    var appSettings = await _settingsDbProvider.getSettings();

    NotificationsHelper.setNotifications(
      appSettings: appSettings,
      notificationsPlugin: FlutterLocalNotificationsPlugin(),
      userAccounts: _session.state.allUsers.toList(),
    );
  }

  Future<void> syncResults() async {
    final users = _session.state.allUsers;

    for (final user in users) {
      try {
        final userMeasurements = await _measurementsDbProvider.getByUser(user.id, isUploaded: false);
        final manualMeasurements = userMeasurements
            .where((x) => x.deviceId == null)
            .map((x) => ManualMeasurementContract.fromEntity(user.muid, x));
        final deviceMeasurements = userMeasurements.where((x) => x.deviceId != null).toList();

        final deviceIds = deviceMeasurements.map((x) => x.deviceId).nonNulls;
        final devices = await _deviceDbProvider.getByIds(deviceIds);

        for (final manualMeasurement in manualMeasurements) {
          await _carePlansRepository.sendManualMeasurement(userId: user.id, manualMeasurement: manualMeasurement);
        }

        final List<MeasurementContract> measurementContracts = [];
        for (final deviceMeasurement in deviceMeasurements) {
          final device = devices.firstWhereOrNull((x) => x.id == deviceMeasurement.deviceId);
          if (device == null) {
            continue;
          }
          final contract = MeasurementContract.fromEntity(
            user.muid,
            deviceMeasurement,
            device.deviceIdentifier,
            device.prototype.modelName,
            device.prototype.deviceManufacturer,
          );
          measurementContracts.add(contract);
        }

        if (measurementContracts.isNotEmpty) {
          await _carePlansRepository.sendMeasurementsFromDevice(
            userId: user.id,
            measurements: measurementContracts,
          );
        }

        await _measurementsDbProvider.updateUserMeasurements(
          user.id,
          const MeasurementsCompanion(isUploaded: Value(true)),
        );

        if (user.permissions.contains(Permissions.viewOwnMeasurementData)) {
          await loadMeasurementResults(user.id);
        }

        await _userDbProvider.updateUser(
          user.id,
          UsersCompanion(
            lastSyncAt: Value(DateTime.now()),
            lastSyncFailed: const Value(false),
            isSessionExpired: const Value(false),
          ),
        );
      } catch (e) {
        //for any failed sync set flag
        await _userDbProvider.updateUser(
          user.id,
          const UsersCompanion(
            lastSyncFailed: Value(true),
          ),
        );
      }
    }
  }
}
