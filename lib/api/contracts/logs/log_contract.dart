import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_contract.g.dart';

@JsonSerializable()
class LogContract{
  final DateTime eventTime;
  final String appVersion;
  final String osVersion;
  final Severity severity;
  final String message;

  const LogContract({
    required this.eventTime,
    required this.appVersion,
    required this.osVersion,
    required this.severity,
    required this.message,
  });

  factory LogContract.fromJson(Map<String, dynamic> json) => _$LogContractFromJson(json);

  Map<String, dynamic> toJson() => _$LogContractToJson(this);

  @override
  String toString() => toJson().toString();
}

enum Severity {
  @JsonValue('Trace')
  trace,
  @JsonValue('Debug')
  debug,
  @JsonValue('Info')
  info,
  @JsonValue('Warning')
  warning,
  @JsonValue('Error')
  error,
  @JsonValue('Critical')
  critical,
}
