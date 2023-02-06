import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/model/user_account.dart';

@immutable
abstract class WarningBlocEvent {
  const WarningBlocEvent();
}

class SessionExpiredWarningBlocEvent extends WarningBlocEvent {
  const SessionExpiredWarningBlocEvent(this.refreshToken);

  final String refreshToken;
}

class RemoveExpiredSessionWarningBlocEvent extends WarningBlocEvent {
  const RemoveExpiredSessionWarningBlocEvent(this.userAccount);
  final UserAccount userAccount;
}

class CarePlanChangedWarningBlocEvent extends WarningBlocEvent {
  const CarePlanChangedWarningBlocEvent(this.carePlan);

  final CarePlan carePlan;
}

class ResolvedWarningDialogBlocEvent extends WarningBlocEvent {
  const ResolvedWarningDialogBlocEvent();
}
