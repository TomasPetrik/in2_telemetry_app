import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan_changes.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/user.dart';

part 'changes_from_date_response.freezed.dart';
part 'changes_from_date_response.g.dart';

@freezed
class ChangesFromDateResponse with _$ChangesFromDateResponse {
  const ChangesFromDateResponse._();

  factory ChangesFromDateResponse(
    CarePlanChanges carePlans,
    User? user,
    List<User>? representedPeople,
    List<Device>? assignedDevices,
  ) = _ChangesFromDateResponse;

  factory ChangesFromDateResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangesFromDateResponseFromJson(json);

  @override
  String toString() => toJson().toString();
}
