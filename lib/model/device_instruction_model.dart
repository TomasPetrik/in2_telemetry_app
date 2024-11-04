import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';

class DeviceInstructionModel {
  final int id;
  final int prototypeId;
  final int userId;
  final int index;
  final String languageCode;
  final InstructionType instructionType;
  final String instructionText;
  final String? image;
  final DateTime lastModifiedTime;

  DeviceInstructionModel(
    this.id,
    this.prototypeId,
    this.userId,
    this.index,
    this.languageCode,
    this.instructionType,
    this.instructionText,
    this.lastModifiedTime, {
    this.image,
  });

  factory DeviceInstructionModel.fromEntity(DeviceInstruction entity) {
    return DeviceInstructionModel(
      entity.id,
      entity.prototypeId,
      entity.userId,
      entity.index,
      entity.languageCode,
      entity.instructionType,
      entity.instructionText,
      entity.lastModifiedTime,
      image: base64Encode(entity.image ?? Uint8List(0)),
    );
  }
}
