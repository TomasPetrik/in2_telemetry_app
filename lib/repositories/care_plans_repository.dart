import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/contracts/care_pan/active_care_plans_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/aggregated_fulfillment_evaluation_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_versions_response.dart';
import 'package:scalesoft_app/api/contracts/measurement/manual_measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';

@singleton
class CarePlansRepository {
  final CarePlanApiClient carePlanApiClient;
  final UserCubit userCubit;

  CarePlansRepository(this.carePlanApiClient, this.userCubit);

  Future<ActiveCarePlansContract> loadActiveCarePlans({
    required int userId,
    int start = 0,
    int count = 100,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    final resp = await carePlanApiClient.loadActiveCarePlans(
      user.hospital.authData.baseUrl,
      user.muid,
      start,
      count,
    );

    return resp;
  }

  Future<CarePlanVersionsContract> loadCarePlanVersions({
    required int userId,
    required int carePlanId,
    int start = 0,
    int count = 100,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    final resp = await carePlanApiClient.loadCarePlanVersions(
      user.hospital.authData.baseUrl,
      carePlanId,
      start,
      count,
    );

    return resp;
  }

  Future<List<MeasurementDataContract>> loadResults({
    required int userId,
    required MeasurementTypeContract measurementType,
    required String startDateTime,
    required String endDateTime,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    final results = await carePlanApiClient.loadResults(
      user.hospital.authData.baseUrl,
      user.muid,
      measurementType.key,
      startDateTime,
      endDateTime,
    );

    return results;
  }

  Future<AggregatedFulfillmentEvaluationContract> loadFullPlanEvaluation({
    required int userId,
    required int carePlanVersionId,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    final fulfillmentPlan = await carePlanApiClient.loadFullPlanEvaluation(
      user.hospital.authData.baseUrl,
      carePlanVersionId,
    );
    return fulfillmentPlan;
  }

  Future<List<FulfillmentEvaluationItem>> loadPartPlanEvaluation({
    required int userId,
    required int carePlanId,
    required String fromDateTime,
    required String toDateTime,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    final items = await carePlanApiClient.loadPartPlanEvaluation(
      user.hospital.authData.baseUrl,
      carePlanId,
      fromDateTime,
      toDateTime,
    );
    return items;
  }

  Future<void> sendMeasurementsFromDevice({
    required int userId,
    required List<MeasurementContract> measurements,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    return carePlanApiClient.sendMeasurementFromDevice(
      user.hospital.authData.baseUrl,
      measurements,
    );
  }

  Future<void> sendManualMeasurement({
    required int userId,
    required ManualMeasurementContract manualMeasurement,
  }) async {
    TokenInterceptor.userId = userId;
    final user = userCubit.getUser(userId);

    return carePlanApiClient.sendManualMeasurement(
      user.hospital.authData.baseUrl,
      manualMeasurement,
    );
  }
}
