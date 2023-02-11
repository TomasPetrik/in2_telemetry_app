import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@singleton
class SyncService {
  final CarePlansRepository _carePlansRepository;

  SyncService(this._carePlansRepository);

  Future<void> loadUserData(final UserAccount userAccount) async {
    //load and assign care plans, fulfillment_evaluation, results
    final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
      userAccount: userAccount,
    );

    for (final carePlan in activeCarePlans.items) {
      carePlan.userId = userAccount.user.muid;
    }

    userAccount.carePlans = activeCarePlans.items;

    await loadFulfillmentEvaluation(userAccount);
    await loadMeasurementResults(userAccount);

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

         await loadFulfillmentEvaluation(representedPerson);
        await loadMeasurementResults(representedPerson);
      }
    }
  }

  Future<void> loadFulfillmentEvaluation(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) {
      return;
    }

    for (final carePlan in carePlans) {
      final fulfillmentEvaluation =
          await _carePlansRepository.loadFulFillmentEvaluation(
        userAccount: userAccount,
        carePlanVersionId: carePlan.versionId,
      );
      carePlan.fulfillmentEvaluation = fulfillmentEvaluation;
    }
  }

  /* load today's and yesterday's measurement results */
  Future<void> loadMeasurementResults(final UserAccount userAccount) async {
    final carePlans = userAccount.carePlans;
    if (carePlans == null) return;

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
}
