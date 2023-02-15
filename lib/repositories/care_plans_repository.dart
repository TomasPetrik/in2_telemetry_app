import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
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

  Future<FulfillmentEvaluation> loadFulFillmentEvaluation({
    required UserAccount userAccount,
    required int carePlanVersionId,
  }) async {
    final items = await carePlanApiClient.loadFullPlanEvaluation(
      userAccount.hospital!.authData.baseUrl,
      carePlanVersionId,
    );
    return FulfillmentEvaluation(items);
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

  Future<void> sendManualMeasurement({
    required UserAccount userAccount,
    required Measurement manualMeasurement,
  }) =>
      carePlanApiClient.sendManualMeasurement(
        userAccount.hospital!.authData.baseUrl,
        manualMeasurement,
      );
}
