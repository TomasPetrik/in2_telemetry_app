import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_bloc_state.freezed.dart';

@freezed
class ReportBlocState with _$ReportBlocState {
  factory ReportBlocState.init() = _Init;
  factory ReportBlocState.failed() = _Failed;
  factory ReportBlocState.sending() = _Sending;
  factory ReportBlocState.succed() = _Succed;
}
