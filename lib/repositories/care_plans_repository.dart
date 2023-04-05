import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/dto/changes_from_date_response.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class CarePlansRepository {
  final CarePlanApiClient carePlanApiClient;
  final Session session;

  CarePlansRepository(this.carePlanApiClient, this.session);

  Future<ActiveCarePlansResponse> loadActiveCarePlans({
    required UserAccount userAccount,
    int start = 0,
    int count = 100,
  }) async {
    final resp = await carePlanApiClient.loadActiveCarePlans(
      userAccount.hospital!.authData.baseUrl,
      userAccount.user.muid,
      start,
      count,
    );

    for (final carePlan in resp.items) {
      carePlan.userId = userAccount.user.muid;
    }

    return resp;
  }

  Future<ChangesFromDateResponse> loadDataChangesFrom({
    required UserAccount userAccount,
    required String fromDateTime,
  }) async {
    final resp = await carePlanApiClient.loadDataChangesFrom(
      userAccount.hospital!.authData.baseUrl,
      fromDateTime,
    );
    return resp;
  }

  Future<List<MeasurementResult>> loadResults({
    required UserAccount userAccount,
    required MeasurementType measurementType,
    required String startDateTime,
    required String endDateTime,
  }) async {
    final results = await carePlanApiClient.loadResults(
      userAccount.hospital!.authData.baseUrl,
      userAccount.user.muid,
      measurementType.key,
      startDateTime,
      endDateTime,
    );

    for (final result in results) {
      result.userId = userAccount.user.muid;
    }

    return results;
  }

  Future<FulfillmentEvaluationAggregated> loadFullPlanEvaluation({
    required UserAccount userAccount,
    required int carePlanVersionId,
  }) async {
    final fulfillmentPlan = await carePlanApiClient.loadFullPlanEvaluation(
      userAccount.hospital!.authData.baseUrl,
      carePlanVersionId,
    );
    return fulfillmentPlan;
  }

  Future<FulfillmentEvaluation> loadPartPlanEvaluation({
    required UserAccount userAccount,
    required int carePlanId,
    required String fromDateTime,
    required String toDateTime,
  }) async {
    final items = await carePlanApiClient.loadPartPlanEvaluation(
      userAccount.hospital!.authData.baseUrl,
      carePlanId,
      fromDateTime,
      toDateTime,
    );
    return FulfillmentEvaluation(items);
  }

  Future<void> sendMeasurementFromDevice({
    required UserAccount userAccount,
    required Measurement measurement,
  }) =>
      carePlanApiClient.sendMeasurementFromDevice(
        userAccount.hospital!.authData.baseUrl,
        [measurement],
      );

  Future<void> sendManualMeasurement({
    required UserAccount userAccount,
    required Measurement manualMeasurement,
  }) =>
      carePlanApiClient.sendManualMeasurement(
        userAccount.hospital!.authData.baseUrl,
        manualMeasurement,
      );

  Future<void> registerDevice({
    required UserAccount userAccount,
    required Device device,
  }) =>
      carePlanApiClient.registerDevice(
        userAccount.hospital!.authData.baseUrl,
        device,
      );
}
