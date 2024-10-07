import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_instructions_template.g.dart';

@JsonSerializable()
class DeviceInstructionsTemplate {
  int localId;
  int prototypeId;
  int index;
  String languageCode;
  String instructionType;
  DateTime lastModifieddTime;
  String text;
  String? base64Image;

  DeviceInstructionsTemplate({
    required this.localId,
    required this.prototypeId,
    required this.index,
    required this.languageCode,
    required this.instructionType,
    required this.lastModifieddTime,
    required this.text,
    this.base64Image,

  });

  factory DeviceInstructionsTemplate.fromJson(Map<String, dynamic> json) => _$DeviceInstructionsTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInstructionsTemplateToJson(this);

  static TypeConverter<DeviceInstructionsTemplate, String> converter = TypeConverter.json(
    fromJson: (json) => DeviceInstructionsTemplate.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );
}
