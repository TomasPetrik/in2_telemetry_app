import 'package:json_annotation/json_annotation.dart';

part 'device_prototype_contract.g.dart';

@JsonSerializable()
class DevicePrototypeContract {
  final int id;
  final String? manufacturer;
  final String modelName;
  final String? aboutUrl;

  DevicePrototypeContract({
    required this.id,
    this.manufacturer,
    required this.modelName,
    this.aboutUrl,
  });

  factory DevicePrototypeContract.fromJson(Map<String, dynamic> json) =>
      _$DevicePrototypeContractFromJson(json);

  Map<String, dynamic> toJson() => _$DevicePrototypeContractToJson(this);

  @override
  String toString() => toJson().toString();
}