import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';

class DeviceInstructionModel {
  final int id;
  final int prototypeId;
  final int index;
  final String languageCode;
  final String instructionType;
  final String instructionText;
  final String? image;
  final DateTime lastModifiedTime;
  bool hasRendered;

  DeviceInstructionModel(
    this.id,
    this.prototypeId,
    this.index,
    this.languageCode,
    this.instructionType,
    this.instructionText,
    this.lastModifiedTime, {
    this.image,
    required this.hasRendered
  });

  factory DeviceInstructionModel.fromEntity(DeviceInstruction entity) {
    return DeviceInstructionModel(
      entity.id,
      entity.prototypeId,
      entity.index,
      entity.languageCode,
      entity.instructionType,
      entity.instructionText,
      entity.lastModifiedTime,
      image: base64Encode(entity.image ?? Uint8List(0)),
      hasRendered: false,
    );
  }
}
