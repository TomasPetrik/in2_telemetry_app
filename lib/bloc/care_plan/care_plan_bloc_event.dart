import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@immutable
abstract class CarePlanBlocEvent {
  const CarePlanBlocEvent();
}

class CarePlanInitializeEvent extends CarePlanBlocEvent {
  const CarePlanInitializeEvent({
    required this.periodTime,
    required this.carePlans,
  });

  final WhenPeriod periodTime;
  final List<CarePlan> carePlans;
}

class TimePeriodChangeEvent extends CarePlanBlocEvent {
  const TimePeriodChangeEvent(this.periodTime);
  final WhenPeriod periodTime;
}

class CurrentPlansChangeEvent extends CarePlanBlocEvent {
  const CurrentPlansChangeEvent(this.carePlans);
  final List<CarePlan> carePlans;
}

class ReloadCarePlansEvent extends CarePlanBlocEvent {
  const ReloadCarePlansEvent(this.userAccount);
  final UserAccount userAccount;
}
