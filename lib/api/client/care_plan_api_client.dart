import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/contracts/care_pan/active_care_plans_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/aggregated_fulfillment_evaluation_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_versions_response.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';

part 'care_plan_api_client.g.dart';

@RestApi(baseUrl: '')
@injectable
abstract class CarePlanApiClient {
  @factoryMethod
  factory CarePlanApiClient(@Named(ConfigurationConstants.privateDioName) Dio dio) =
      _CarePlanApiClient;

  @GET('{apiUrl}/patient/care-plan/active')
  Future<ActiveCarePlansContract> loadActiveCarePlans(
    @Path('apiUrl') String apiUrl,
    @Query('patientMuid') String patientMuid,
    @Query('start') int start,
    @Query('count') int count,
  );

  @GET(
    '{apiUrl}/patient/me/care-plan/{carePlanId}/version?start={start}&count={count}',
  )
  Future<CarePlanVersionsContract> loadCarePlanVersions(
    @Path('apiUrl') String apiUrl,
    @Path('carePlanId') int carePlanId,
    @Path('start') int start,
    @Path('count') int count,
  );

  @GET('{apiUrl}/patient/measurement')
  Future<List<MeasurementDataContract>> loadResults(
    @Path('apiUrl') String apiUrl,
    @Query('patientMuid') String patientMuid,
    @Query('type') String measurementType,
    @Query('start') String startDateTime,
    @Query('end') String endDateTime,
  );

  @GET(
    '{apiUrl}/patient/me/care-plan/version/{carePlanVersionId}/fulfillment-evaluation',
  )
  Future<List<FulfillmentEvaluationItem>> loadFullPlanEvaluationIntervals(
    @Path('apiUrl') String apiUrl,
    @Path('carePlanVersionId') int carePlanVersionId,
  );

  @GET(
    '{apiUrl}/patient/me/care-plan/version/{carePlanVersionId}/fulfillment-evaluation-aggregated',
  )
  Future<AggregatedFulfillmentEvaluationContract> loadFullPlanEvaluation(
    @Path('apiUrl') String apiUrl,
    @Path('carePlanVersionId') int carePlanVersionId,
  );

  @GET(
    '{apiUrl}/patient/me/care-plan/{carePlanId}/fulfillment-evaluation?from={from}&to={to}',
  )
  Future<List<FulfillmentEvaluationItem>> loadPartPlanEvaluation(
    @Path('apiUrl') String apiUrl,
    @Path('carePlanId') int carePlanId,
    @Path('from') String fromDate,
    @Path('to') String toDate,
  );

  @POST('{apiUrl}/patient/measurement-batch')
  Future<void> sendMeasurementFromDevice(
    @Path('apiUrl') String apiUrl,
    @Body() List<MeasurementContract> measurements,
  );

  @POST('{apiUrl}/patient/manual-measurement')
  Future<void> sendManualMeasurement(
    @Path('apiUrl') String apiUrl,
    @Body() MeasurementContract manualMeasurement,
  );
}
