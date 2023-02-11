import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

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
  Future<List<FulfillmentEvaluationItem>> loadFullPlanEvaluation(
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

  @POST('{apiUrl}/patient/manual-measurement')
  Future<void> sendManualMeasurement(
    @Path('apiUrl') String apiUrl,
    @Body() Measurement manualMeasurement,
  );
}
