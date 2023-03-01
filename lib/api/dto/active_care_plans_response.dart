import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';

part 'active_care_plans_response.freezed.dart';
part 'active_care_plans_response.g.dart';

@freezed
class ActiveCarePlansResponse with _$ActiveCarePlansResponse {
  const ActiveCarePlansResponse._();

  factory ActiveCarePlansResponse(
    final int count,
    final List<CarePlan> items,
  ) = _ActiveCarePlans;

  factory ActiveCarePlansResponse.fromJson(Map<String, dynamic> json) =>
      _$ActiveCarePlansResponseFromJson(json);

  @override
  String toString() => toJson().toString();
}
