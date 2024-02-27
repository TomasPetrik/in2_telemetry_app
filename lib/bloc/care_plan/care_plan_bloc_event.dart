import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
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
  final List<CarePlanContract> carePlans;
  final List<Measurement> pendingResults;
}

class TimePeriodChangeEvent extends CarePlanBlocEvent {
  const TimePeriodChangeEvent(this.whenPeriod);
  final PlanWhenPeriod whenPeriod;
}

class CurrentPlansChangeEvent extends CarePlanBlocEvent {
  const CurrentPlansChangeEvent(
    this.measurementType,
  );
  final MeasurementTypeContract? measurementType;
}

class ReloadCarePlansEvent extends CarePlanBlocEvent {
  const ReloadCarePlansEvent();
}

class RefreshStateEvent extends CarePlanBlocEvent {
  const RefreshStateEvent();
}
