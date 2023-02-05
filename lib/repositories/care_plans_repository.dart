import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/care_plan_api_client.dart';
import 'package:scalesoft_app/api/dto/active_care_plans_response.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class CarePlansRepository {
  final CarePlanApiClient carePlanApiClient;
  final Session session;

  CarePlansRepository(this.carePlanApiClient, this.session);
  Future<ActiveCarePlansResponse> loadActiveCarePlans({
    required UserAccount userAccount,
    // required String patientMuid,
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

  Future<FulfillmentEvaluation> loadFulFillmentEvaluation({
    required int carePlanVersionId,
  }) async {
    final items = await carePlanApiClient.loadFulFillmentEvaluation(
      session.userAccount!.hospital!.authData.baseUrl,
      carePlanVersionId,
    );
    return FulfillmentEvaluation(items);
  }
}
