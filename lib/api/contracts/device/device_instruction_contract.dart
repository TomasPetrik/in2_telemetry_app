import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'device_instruction_contract.g.dart';

@JsonSerializable()
class DeviceInstructionContract {
  final int id;
  final int devicePrototypeId;
  final int index;
  final String languageCode;
  final String instructionType;
  final DateTime lastModifieddTime;
  final String text;
  final String? image;

  DeviceInstructionContract({
    required this.id,
    required this.devicePrototypeId,
    required this.index,
    required this.languageCode,
    required this.instructionType,
    required this.lastModifieddTime,
    required this.text,
    this.image
  });

  factory DeviceInstructionContract.fromJson(Map<String, dynamic> json) =>
      _$DeviceInstructionContractFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInstructionContractToJson(this);

  @override
  String toString() => toJson().toString();
}