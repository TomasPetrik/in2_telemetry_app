import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/report/report.dart';

part 'report_request.freezed.dart';
part 'report_request.g.dart';
part 'report_request.hive.dart';

@freezed
class ReportRequest with _$ReportRequest {
  const ReportRequest._();

  @HiveType(typeId: 62, adapterName: 'ReportRequestAdapter')
  const factory ReportRequest({
    @HiveField(0) required String appIdentifier,
    @HiveField(1) required String phoneModel,
    @HiveField(2) required List<Report> logs,
  }) = _ReportRequest;

  factory ReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestFromJson(json);

  @override
  String toString() => toJson().toString();
}
