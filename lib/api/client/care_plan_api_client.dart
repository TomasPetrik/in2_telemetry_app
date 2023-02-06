import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/measurement/manual_measurement.dart';
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

  @GET(
    '{apiUrl}/patient/me/care-plan/version/{carePlanVersionId}/fulfillment-evaluation',
  )
  Future<List<FulfillmentEvaluationItem>> loadFulFillmentEvaluation(
    @Path('apiUrl') String apiUrl,
    @Path('carePlanVersionId') int carePlanVersionId,
  );

  @POST('{apiUrl}/patient/manual-measurement')
  Future<void> sendManualMeasurement(
     @Path('apiUrl') String apiUrl,
    @Body() ManualMeasurement manualMeasurement,
  );
}
