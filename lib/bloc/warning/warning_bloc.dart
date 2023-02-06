import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_event.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';

@singleton
class WarningBloc extends Bloc<WarningBlocEvent, WarningBlocState> {
  final AccountDbProvider _accountDbProvider;

  WarningBloc(this._accountDbProvider) : super(WarningBlocState(warnings: [])) {
    on<SessionExpiredWarningBlocEvent>(_onSessionExpiredWarningBlocEvent);
    on<RemoveExpiredSessionWarningBlocEvent>(
      _onRemoveExpiredSessionWarningBlocEvent,
    );
    on<CarePlanChangedWarningBlocEvent>(_onCarePlanChangedWarningBlocEvent);
    on<ResolvedWarningDialogBlocEvent>(_onResolvedWarningDialogBlocEvent);
  }

  Future<void> _onSessionExpiredWarningBlocEvent(
    SessionExpiredWarningBlocEvent event,
    Emitter<WarningBlocState> emit,
  ) async {
    final expiredUser =
        await _accountDbProvider.setExpiredUserByToken(event.refreshToken);

    emit(
      state.copyWith(
        warnings: state.warnings
          ..add(
            Warning(WarningType.expiredSession, expiredUser!),
          ),
        wasResolved: false,
      ),
    );
  }

  Future<void> _onRemoveExpiredSessionWarningBlocEvent(
    RemoveExpiredSessionWarningBlocEvent event,
    Emitter<WarningBlocState> emit,
  ) async {
    final warnings = state.warnings;
    warnings.removeWhere(
      (warning) {
        return warning.warningType == WarningType.expiredSession &&
            (warning.object as UserAccount).user.muid ==
                event.userAccount.user.muid;
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
        wasResolved: false,
      ),
    );
  }

  Future<void> _onResolvedWarningDialogBlocEvent(
    ResolvedWarningDialogBlocEvent event,
    Emitter<WarningBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        wasResolved: true,
      ),
    );
  }
}
