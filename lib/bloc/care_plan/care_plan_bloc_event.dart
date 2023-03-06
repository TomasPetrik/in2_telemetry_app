import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@immutable
abstract class CarePlanBlocEvent {
  const CarePlanBlocEvent();
}

class CarePlanInitializeEvent extends CarePlanBlocEvent {
  const CarePlanInitializeEvent({
    required this.whenPeriod,
    required this.carePlans,
    required this.pendingResults,
  });

  final PlanWhenPeriod whenPeriod;
  final List<CarePlan> carePlans;
  final List<Measurement>? pendingResults;
}

class TimePeriodChangeEvent extends CarePlanBlocEvent {
  const TimePeriodChangeEvent(this.whenPeriod);
  final PlanWhenPeriod whenPeriod;
}

class CurrentPlansChangeEvent extends CarePlanBlocEvent {
  const CurrentPlansChangeEvent(
    this.measurementType,
  );
  final MeasurementType? measurementType;
}

class ReloadCarePlansEvent extends CarePlanBlocEvent {
  const ReloadCarePlansEvent();
}

class RefreshStateEvent extends CarePlanBlocEvent {
  const RefreshStateEvent();
}

class StopWatchDog extends CarePlanBlocEvent {
  const StopWatchDog();
}
