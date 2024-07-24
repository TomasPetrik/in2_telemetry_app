import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/assigned_device_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/measurement_thresholds_contract.dart';

part 'user_contract.g.dart';

@JsonSerializable()
class UserContract {
  final String muid;
  final List<String> firstNames;
  final List<String> lastNames;
  @JsonKey(defaultValue: [])
  final List<String>? phoneNumbers;
  @JsonKey(defaultValue: [])
  final List<String>? emailAddresses;
  final MeasurementThresholdsContract? measurementThresholds;
  final List<AssignedDeviceContract>? assignedDevices;

  UserContract({
    required this.muid,
    required this.firstNames,
    required this.lastNames,
    this.phoneNumbers,
    this.emailAddresses,
    this.measurementThresholds,
    this.assignedDevices,
  });

  factory UserContract.fromJson(Map<String, dynamic> json) => _$UserContractFromJson(json);

  Map<String, dynamic> toJson() => _$UserContractToJson(this);

  @override
  String toString() => toJson().toString();

  String get fullName => [...firstNames, ...lastNames].join(' ');
}
