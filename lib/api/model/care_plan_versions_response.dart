import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_version.dart';

part 'care_plan_versions_response.freezed.dart';
part 'care_plan_versions_response.g.dart';

@freezed
class CarePlanVersionsResponse with _$CarePlanVersionsResponse {
  const CarePlanVersionsResponse._();

  factory CarePlanVersionsResponse(
    final int count,
    final List<CarePlanVersion> items,
  ) = _CarePlanVersionsResponse;

  factory CarePlanVersionsResponse.fromJson(Map<String, dynamic> json) =>
      _$CarePlanVersionsResponseFromJson(json);

  @override
  String toString() => toJson().toString();
}
