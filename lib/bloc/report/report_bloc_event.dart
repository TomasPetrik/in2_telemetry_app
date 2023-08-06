import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_bloc_event.freezed.dart';

@freezed
class ReportBlocEvent with _$ReportBlocEvent {
  const factory ReportBlocEvent.init() = _Init;
  const factory ReportBlocEvent.sendReports() = _SendReports;
}
