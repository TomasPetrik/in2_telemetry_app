import 'package:json_annotation/json_annotation.dart';

part 'source_device_contract.g.dart';

@JsonSerializable()
class SourceDeviceContract {
  final String deviceIdentifier;
  final String modelName;
  final String? deviceManufacturer;

  SourceDeviceContract({
    required this.deviceIdentifier,
    required this.modelName,
    this.deviceManufacturer,
  });

  factory SourceDeviceContract.fromJson(Map<String, dynamic> json) => _$SourceDeviceContractFromJson(json);

  Map<String, dynamic> toJson() => _$SourceDeviceContractToJson(this);

  @override
  String toString() => toJson().toString();
}
