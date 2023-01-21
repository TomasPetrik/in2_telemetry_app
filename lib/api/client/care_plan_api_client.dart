import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

part 'care_plan_api_client.g.dart';

@RestApi()
@injectable
abstract class CarePlanApiClient {
  @factoryMethod
  factory CarePlanApiClient(@Named(Constants.privateDioName) Dio dio) =
      _CarePlanApiClient;

  @GET('/patient/care-plan/active')
  Future<ActiveCarePlansResponse> loadActiveCarePlans(
    @Query('patientMuid') String patientMuid,
    @Query('start') int start,
    @Query('count') int count,
  );
}
