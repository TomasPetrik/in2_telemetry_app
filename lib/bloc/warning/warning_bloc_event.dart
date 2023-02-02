import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';

@immutable
abstract class WarningBlocEvent {
  const WarningBlocEvent();
}

class SessionExpiredWarningBlocEvent extends WarningBlocEvent {
  const SessionExpiredWarningBlocEvent();
}

class RemoveExpiredSessionWarningBlocEvent extends WarningBlocEvent {
  const RemoveExpiredSessionWarningBlocEvent();
}

class CarePlanChangedWarningBlocEvent extends WarningBlocEvent {
  const CarePlanChangedWarningBlocEvent(this.carePlan);

  final CarePlan carePlan;
}
