import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/contracts/care_pan/active_care_plans_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/aggregated_fulfillment_evaluation_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_versions_response.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class CarePlansRepository {
  final CarePlanApiClient carePlanApiClient;
  final Session session;

  CarePlansRepository(this.carePlanApiClient, this.session);

  Future<ActiveCarePlansContract> loadActiveCarePlans({
    required UserAccount userAccount,
    int start = 0,
    int count = 100,
  }) async {
    session.token = userAccount.authToken;
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

  Future<CarePlanVersionsContract> loadCarePlanVersions({
    required UserAccount userAccount,
    required CarePlanContract carePlan,
    int start = 0,
    int count = 100,
  }) async {
    session.token = userAccount.authToken;
    final resp = await carePlanApiClient.loadCarePlanVersions(
      userAccount.hospital!.authData.baseUrl,
      carePlan.id,
      start,
      count,
    );

    return resp;
  }

  Future<List<MeasurementDataContract>> loadResults({
    required UserAccount userAccount,
    required MeasurementTypeContract measurementType,
    required String startDateTime,
    required String endDateTime,
  }) async {
    session.token = userAccount.authToken;
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

  Future<AggregatedFulfillmentEvaluationContract> loadFullPlanEvaluation({
    required UserAccount userAccount,
    required int carePlanVersionId,
  }) async {
    session.token = userAccount.authToken;
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
    session.token = userAccount.authToken;
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
  }) {
    session.token = userAccount.authToken;
    return carePlanApiClient.sendMeasurementFromDevice(
      userAccount.hospital!.authData.baseUrl,
      [measurement],
    );
  }

  Future<void> sendManualMeasurement({
    required UserAccount userAccount,
    required Measurement manualMeasurement,
  }) {
    session.token = userAccount.authToken;
    return carePlanApiClient.sendManualMeasurement(
      userAccount.hospital!.authData.baseUrl,
      manualMeasurement,
    );
  }
}
