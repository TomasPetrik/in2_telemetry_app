import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class CarePlansRepository {
  final CarePlanApiClient carePlanApiClient;
  final Session session;

  CarePlansRepository(this.carePlanApiClient, this.session);
  Future<ActiveCarePlansResponse> loadActiveCarePlans({
    required String patientMuid,
    int start = 0,
    int count = 100,
  }) =>
      carePlanApiClient.loadActiveCarePlans(
        session.hospital!.authData.baseUrl,
        patientMuid,
        start,
        count,
      );

  Future<FulfillmentEvaluation> loadFulFillmentEvaluation({
    required int carePlanVersionId,
  }) async {
    final items = await carePlanApiClient.loadFulFillmentEvaluation(
      session.hospital!.authData.baseUrl,
      carePlanVersionId,
    );
    return FulfillmentEvaluation(items);
  }
}
