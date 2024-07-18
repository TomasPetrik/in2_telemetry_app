import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';

part 'source_device_with_metadata_contract.g.dart';

@JsonSerializable()
class SourceDeviceWithMetadataContract {
  final SourceDeviceContract? sourceDevice;

  const SourceDeviceWithMetadataContract({
    this.sourceDevice,
  });

  factory SourceDeviceWithMetadataContract.fromJson(Map<String, dynamic> json) =>
      _$SourceDeviceWithMetadataContractFromJson(json);

  Map<String, dynamic> toJson() => _$SourceDeviceWithMetadataContractToJson(this);

  @override
  String toString() => toJson().toString();
}