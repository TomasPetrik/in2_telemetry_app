import 'package:json_annotation/json_annotation.dart';

part 'assigned_device_contract.g.dart';

@JsonSerializable()
class AssignedDeviceContract {
  final String deviceIdentifier;
  final String modelName;
  final String? deviceManufacturer;
  final String? assignedIdentifier;
  final String? bluetoothAddress;

  AssignedDeviceContract({
    required this.deviceIdentifier,
    required this.modelName,
    this.deviceManufacturer,
    this.assignedIdentifier,
    this.bluetoothAddress,
  });

  factory AssignedDeviceContract.fromJson(Map<String, dynamic> json) => _$AssignedDeviceContractFromJson(json);

  Map<String, dynamic> toJson() => _$AssignedDeviceContractToJson(this);

  @override
  String toString() => toJson().toString();

  // TODO: Move this
  /// Checks if [this] and [other] device refer to the same real-world device
  bool isEquivalentTo(AssignedDeviceContract other) {
    return (deviceIdentifier == other.deviceIdentifier &&
        modelName == other.modelName &&
        deviceManufacturer == other.deviceManufacturer);
  }
}
