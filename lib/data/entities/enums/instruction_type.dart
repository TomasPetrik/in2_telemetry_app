import 'package:json_annotation/json_annotation.dart';

enum InstructionType {
  @JsonValue("Pairing") pairing,
  @JsonValue("Measuring") measuring,
}