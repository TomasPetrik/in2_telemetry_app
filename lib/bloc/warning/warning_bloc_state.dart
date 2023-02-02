import 'package:freezed_annotation/freezed_annotation.dart';

part 'warning_bloc_state.freezed.dart';

@unfreezed
class WarningBlocState with _$WarningBlocState {
  factory WarningBlocState({required List<Warning> warnings}) =
      _WarningBlocState;
}

enum WarningType {
  expiredSession,
  changedPlan,
}

class Warning {
  WarningType warningType;
  Object object;

  Warning(this.warningType, this.object);
}
