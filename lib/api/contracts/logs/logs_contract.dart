import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/logs/log_contract.dart';

part 'logs_contract.g.dart';

@JsonSerializable()
class LogsContract {
  final String appIdentifier;
  final String phoneModel;
  final List<LogContract> logs;

  const LogsContract({
    required this.appIdentifier,
    required this.phoneModel,
    required this.logs,
  });

  factory LogsContract.fromJson(Map<String, dynamic> json) => _$LogsContractFromJson(json);

  Map<String, dynamic> toJson() => _$LogsContractToJson(this);

  @override
  String toString() => toJson().toString();
}
