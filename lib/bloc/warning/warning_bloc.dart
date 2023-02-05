import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_event.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class WarningBloc extends Bloc<WarningBlocEvent, WarningBlocState> {
  final Session _session;

  WarningBloc(this._session) : super(WarningBlocState(warnings: [])) {
    on<SessionExpiredWarningBlocEvent>(_onSessionExpiredWarningBlocEvent);
    on<RemoveExpiredSessionWarningBlocEvent>(
      _onRemoveExpiredSessionWarningBlocEvent,
    );
    on<CarePlanChangedWarningBlocEvent>(_onCarePlanChangedWarningBlocEvent);
  }

  Future<void> _onSessionExpiredWarningBlocEvent(
    SessionExpiredWarningBlocEvent event,
    Emitter<WarningBlocState> emit,
  ) async {
    _session.userAccount?.sessionExpired = true;

    emit(
      state.copyWith(
        warnings: state.warnings
          ..add(
            Warning(WarningType.expiredSession, _session.userAccount!),
          ),
      ),
    );
  }

  Future<void> _onRemoveExpiredSessionWarningBlocEvent(
    RemoveExpiredSessionWarningBlocEvent event,
    Emitter<WarningBlocState> emit,
  ) async {
    _session.userAccount?.sessionExpired = false;

    final warnings = state.warnings;
    warnings.removeWhere(
      (warning) {
        return warning.warningType == WarningType.expiredSession &&
            (warning.object as UserAccount).user.muid ==
                _session.userAccount?.user.muid;
      },
    );

    emit(
      state.copyWith(
        warnings: warnings,
      ),
    );
  }

  Future<void> _onCarePlanChangedWarningBlocEvent(
    CarePlanChangedWarningBlocEvent event,
    Emitter<WarningBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        warnings: state.warnings
          ..add(
            Warning(WarningType.changedPlan, event.carePlan),
          ),
      ),
    );
  }
}
