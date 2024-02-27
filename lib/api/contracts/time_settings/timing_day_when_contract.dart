import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_when_type.dart';
import 'package:scalesoft_app/api/contracts/time_settings/when_code_contract.dart';

part 'timing_day_when_contract.g.dart';

@JsonSerializable()
class TimingDayWhenContract {
  final TimingDayWhenTypeContract type;
  final String start;
  final String end;
  final String? timeOfDay;
  final WhenCodeContract? whenCode;

  TimingDayWhenContract({
    required this.type,
    required this.start,
    required this.end,
    this.timeOfDay,
    this.whenCode
  });

  factory TimingDayWhenContract.fromJson(Map<String, dynamic> json) => _$TimingDayWhenContractFromJson(json);
  Map<String, dynamic> toJson() => _$TimingDayWhenContractToJson(this);

  @override
  String toString() => toJson().toString();
}