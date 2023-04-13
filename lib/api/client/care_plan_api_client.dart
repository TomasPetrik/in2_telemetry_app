import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/model/active_care_plans_response.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/model/changes_from_date_response.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/utils/constants.dart';

part 'care_plan_api_client.g.dart';

@RestApi(baseUrl: '')
@injectable
abstract class CarePlanApiClient {
  @factoryMethod
  factory CarePlanApiClient(@Named(Constants.privateDioName) Dio dio) =
      _CarePlanApiClient;

  @GET('{apiUrl}/patient/care-plan/active')
  Future<ActiveCarePlansResponse> loadActiveCarePlans(
    @Path('apiUrl') String apiUrl,
    @Query('patientMuid') String patientMuid,
    @Query('start') int start,
    @Query('count') int count,
  );

  @GET('{apiUrl}/patient/measurement')
  Future<List<MeasurementResult>> loadResults(
    @Path('apiUrl') String apiUrl,
    @Query('patientMuid') String patientMuid,
    @Query('type') String measurementType,
    @Query('start') String startDateTime,
    @Query('end') String endDateTime,
  );

  @GET(
    '{apiUrl}/patient/me/care-plan/version/{carePlanVersionId}/fulfillment-evaluation',
  )
  Future<List<FulfillmentEvaluationItem>> loadFullPlanEvaluationIntervalls(
    @Path('apiUrl') String apiUrl,
    @Path('carePlanVersionId') int carePlanVersionId,
  );

  @GET(
    '{apiUrl}/patient/me/care-plan/version/{carePlanVersionId}/fulfillment-evaluation-aggregated',
  )
  Future<FulfillmentEvaluationAggregated> loadFullPlanEvaluation(
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

  @GET('{apiUrl}/patient/me/changes-from-date?from={from}')
  Future<ChangesFromDateResponse> loadDataChangesFrom(
    @Path('apiUrl') String apiUrl,
    @Path('from') String fromDate,
  );

  @POST('{apiUrl}/patient/measurement-batch')
  Future<void> sendMeasurementFromDevice(
    @Path('apiUrl') String apiUrl,
    @Body() List<Measurement> measurements,
  );

  @POST('{apiUrl}/patient/manual-measurement')
  Future<void> sendManualMeasurement(
    @Path('apiUrl') String apiUrl,
    @Body() Measurement manualMeasurement,
  );

  @POST('{apiUrl}/patient/register-device')
  Future<void> registerDevice(
    @Path('apiUrl') String apiUrl,
    @Body() Device device,
  );
}
