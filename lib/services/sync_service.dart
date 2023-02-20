import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@singleton
class SyncService {
  final Session _session;
  final AccountDbProvider _accountDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final CarePlansRepository _carePlansRepository;

  SyncService(
    this._session,
    this._accountDbProvider,
    this._pendingResultsDbProvider,
    this._carePlansRepository,
  );

  Future<void> loadUserData(final UserAccount userAccount) async {
    //load and assign care plans, fulfillment_evaluation, results
    final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
      userAccount: userAccount,
    );

    for (final carePlan in activeCarePlans.items) {
      carePlan.userId = userAccount.user.muid;
    }

    userAccount.carePlans = activeCarePlans.items;

    await loadFulFillmentEvaluation(userAccount);
    await loadPartPlanEvaluation(userAccount);
    if (userAccount.viewOwnMeasurementData) {
      await loadMeasurementResults(userAccount);
    }

    userAccount.carePlans = activeCarePlans.items;
    if (userAccount.representedPeople?.isNotEmpty == true) {
      for (final UserAccount representedPerson
          in userAccount.representedPeople!) {
        final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
          userAccount: representedPerson,
        );

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

  Future<void> loadFulFillmentEvaluation(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) {
      return;
    }

    for (final carePlan in carePlans) {
      try {
        final fullPlanEvaluation =
            await _carePlansRepository.loadFullPlanEvaluation(
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

    final yesterdayMidnight = DateTime.now().getYesterdayMidnight();
    var tomorrowMidnight = DateTime.now().getTomorrowMidnight();

    for (final carePlan in carePlans) {
      if (carePlan.scheduledEnd?.isBefore(tomorrowMidnight) == true) {
        if (carePlan.scheduledEnd?.isBefore(yesterdayMidnight) == true) {
          debugPrint(
            'skipping load last two days evaluation for planId = ${carePlan.id}',
          );
          continue;
        }
        tomorrowMidnight = carePlan.scheduledEnd!.toUtc();
      }

      final lastTwoDaysEvaluation =
          await _carePlansRepository.loadPartPlanEvaluation(
        userAccount: userAccount,
        carePlanId: carePlan.id,
        fromDateTime: yesterdayMidnight.toIso8601String(),
        toDateTime: tomorrowMidnight.toIso8601String(),
      );
      carePlan.lastTwoDaysEvaluation = lastTwoDaysEvaluation;
    }
  }

  /* load today's and yesterday's measurement results */
  Future<void> loadMeasurementResults(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) return;

    //TODO.. load measurement results regardless care plans, because he could try to measure something
    //for for each supported measurement hit endpoint for measurements,
    //this will also affect results page which could be possibly filled even without care plans

    final supportedMeasurementTypes =
        CarePlanHelper.getMeasurementTypes(carePlans);

    final yesterdayMidnight = DateTime.now().getYesterdayMidnight();
    final tomorrowMidnight = DateTime.now().getTomorrowMidnight();

    final List<MeasurementResult> allResults = [];
    for (final mesurementType in supportedMeasurementTypes) {
      final measurementResults = await _carePlansRepository.loadResults(
        userAccount: userAccount,
        measurementType: mesurementType,
        startDateTime: yesterdayMidnight.toIso8601String(),
        endDateTime: tomorrowMidnight.toIso8601String(),
      );
      allResults.addAll(measurementResults);
    }
    userAccount.measurementResults = allResults;
  }

  Future<void> syncAllData() async {
    final userAccounts = _session.getSessionAccounts();

    for (final userAccount in userAccounts) {
      try {
        await loadUserData(userAccount);
        userAccount.lastSyncAt = DateTime.now();
        userAccount.lastSyncFailed = false;
        await _accountDbProvider.save(userAccount);
      } on DioError {
        //for any failed sync set flag
        userAccount.lastSyncFailed = true;
        await _accountDbProvider.save(userAccount);
        return;
      }
    }
  }

  Future<void> syncResults() async {
    final Set<String> allowedUsersMuids = _session
        .getSessionAccounts()
        .map((userAccount) => userAccount.user.muid)
        .toSet();

    for (final userId in allowedUsersMuids) {
      final userAccount = _accountDbProvider.get(userId);
      if (userAccount == null) {
        _pendingResultsDbProvider.removeUserResults(userId);
        continue;
      }

      try {
        final userMeasurements = _pendingResultsDbProvider.getPerUser(userId);
        if (userMeasurements == null || userMeasurements.isEmpty == true) {
          continue;
        }

        for (final userMeasurement in userMeasurements) {
          //TODO.. distinguish if it was manual or regular measurement by sourceDevice presence
          await _carePlansRepository.sendManualMeasurement(
            userAccount: userAccount,
            manualMeasurement: userMeasurement,
          );
          await _pendingResultsDbProvider.remove(userMeasurement);
        }
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
