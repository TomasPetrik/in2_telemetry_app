import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/report/report_bloc_event.dart';
import 'package:scalesoft_app/bloc/report/report_bloc_state.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';

@injectable
class ReportBloc extends Bloc<ReportBlocEvent, ReportBlocState>
    with BottomSheetMixin {
  final ReportService _reportService;
  late final BuildContext context;

  ReportBloc(this._reportService) : super(ReportBlocState.succed()) {
    on<ReportBlocEvent>((event, emit) async {
      await event.when(
        init: (context) async {
          this.context = context;
        },
        sendReports: () async {
          try {
            await _reportService.syncReports();
            emit(ReportBlocState.succed());
          } catch (_) {
            showServerError(context);
            emit(ReportBlocState.failed());
          }
        },
      );
    });
  }
}
