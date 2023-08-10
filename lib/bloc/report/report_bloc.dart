import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/report/report_bloc_event.dart';
import 'package:scalesoft_app/bloc/report/report_bloc_state.dart';
import 'package:scalesoft_app/services/report_service.dart';

@injectable
class ReportBloc extends Bloc<ReportBlocEvent, ReportBlocState> {
  final ReportService _reportService;

  ReportBloc(this._reportService) : super(ReportBlocState.succed()) {
    on<ReportBlocEvent>((event, emit) async {
      await event.when(
        init: () async {
          emit(ReportBlocState.init());
        },
        sendReports: () async {
          try {
            emit(ReportBlocState.sending());
            await _reportService.syncReports();
            emit(ReportBlocState.succed());
          } catch (_) {
            emit(ReportBlocState.failed());
          }
        },
      );
    });
  }
}
