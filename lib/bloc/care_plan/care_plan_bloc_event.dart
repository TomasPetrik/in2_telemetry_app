import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@immutable
abstract class CarePlanBlocEvent {
  const CarePlanBlocEvent();
}

class CarePlanInitializeEvent extends CarePlanBlocEvent {
  const CarePlanInitializeEvent({
    required this.whenPeriod,
    required this.carePlans,
    required this.uncategorizedResults,
    required this.pendingResults,
  });

  final PlanWhenPeriod whenPeriod;
  final List<CarePlan> carePlans;
  final List<MeasurementResult> uncategorizedResults;
  final List<Measurement>? pendingResults;
}

class TimePeriodChangeEvent extends CarePlanBlocEvent {
  const TimePeriodChangeEvent(this.whenPeriod);
  final PlanWhenPeriod whenPeriod;
}

class CurrentPlansChangeEvent extends CarePlanBlocEvent {
  CurrentPlansChangeEvent(
    this.carePlans,
    this.measurementType,
  );
  final List<CarePlan> carePlans;
  MeasurementType? measurementType;
}

class ReloadCarePlansEvent extends CarePlanBlocEvent {
  const ReloadCarePlansEvent(this.userAccount);
  final UserAccount userAccount;
}
