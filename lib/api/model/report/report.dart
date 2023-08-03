import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'report.freezed.dart';
part 'report.g.dart';
part 'report.hive.dart';

@freezed
class Report with _$Report {
  const Report._();

  @HiveType(typeId: 60, adapterName: 'ReportAdapter')
  const factory Report({
    @HiveField(0) DateTime? eventTime,
    @HiveField(1) String? appVersion,
    @HiveField(2) String? osVersion,
    @HiveField(3) Severity? severity,
    @HiveField(4) String? message,
    @JsonKey(includeToJson: false) @HiveField(5) String? patientMuid,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 61)
enum Severity {
  @JsonValue('Trace')
  @HiveField(0)
  trace,
  @JsonValue('Debug')
  @HiveField(1)
  debug,
  @JsonValue('Info')
  @HiveField(2)
  info,
  @JsonValue('Warning')
  @HiveField(3)
  warning,
  @JsonValue('Error')
  @HiveField(4)
  error,
  @JsonValue('Critical')
  @HiveField(5)
  critical,
}
