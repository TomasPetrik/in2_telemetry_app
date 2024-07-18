import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/assigned_device_contract.dart';
import 'package:scalesoft_app/api/contracts/user/user_contract.dart';

part 'current_user_info_contract.g.dart';

@JsonSerializable()
class CurrentUserInfoContract {
  final UserContract currentUser;
  final List<UserContract>? representedPeople;
  final List<AssignedDeviceContract>? assignedDevices;

  const CurrentUserInfoContract({
    required this.currentUser,
    this.representedPeople,
    this.assignedDevices,
  });

  factory CurrentUserInfoContract.fromJson(Map<String, dynamic> json) => _$CurrentUserInfoContractFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserInfoContractToJson(this);

  @override
  String toString() => toJson().toString();
}
