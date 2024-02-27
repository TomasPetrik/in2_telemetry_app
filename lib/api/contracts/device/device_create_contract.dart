import 'package:json_annotation/json_annotation.dart';

part 'device_create_contract.g.dart';

@JsonSerializable(explicitToJson: true)
class DeviceCreateContract {
  final int deviceModelId;
  final String? assignedIdentifier;
  final String deviceIdentifier;
  final String? imei;
  final String? bluetoothAddress;
  final String? wifiMacAddress;
  final String? note;

  DeviceCreateContract({
    required this.deviceModelId,
    this.assignedIdentifier,
    required this.deviceIdentifier,
    this.imei,
    this.bluetoothAddress,
    this.wifiMacAddress,
    this.note,
  });

  factory DeviceCreateContract.fromJson(Map<String, dynamic> json) => _$DeviceCreateContractFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceCreateContractToJson(this);

  @override
  String toString() => toJson().toString();
}