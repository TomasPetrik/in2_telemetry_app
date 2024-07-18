import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';

part 'time_setting.g.dart';

@JsonSerializable()
class TimeSetting {
  WhenCode code;
  TimeOnly start;
  TimeOnly end;

  TimeSetting({
    required this.code,
    required this.start,
    required this.end,
  });

  factory TimeSetting.fromJson(Map<String, dynamic> json) => _$TimeSettingFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSettingToJson(this);

  static TypeConverter<List<TimeSetting>, String> listConverter = TypeConverter.json(
    fromJson: (fromDb) =>
        (jsonDecode(fromDb).cast<Map<String, dynamic>>()).map<TimeSetting>(TimeSetting.fromJson).toList(),
    toJson: (obj) => json.encode(obj),
  );
}
