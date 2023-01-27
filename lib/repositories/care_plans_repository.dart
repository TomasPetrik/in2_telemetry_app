import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';

@singleton
class CarePlansRepository {
  final CarePlanApiClient carePlanApiClient;

  CarePlansRepository(this.carePlanApiClient);
  Future<ActiveCarePlansResponse> loadActiveCarePlans({
    required String patientMuid,
     int start = 0,
     int count = 100,
  }) =>
      carePlanApiClient.loadActiveCarePlans(
        patientMuid,
        start,
        count,
      );
}
