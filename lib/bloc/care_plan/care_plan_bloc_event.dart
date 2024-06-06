import 'package:flutter/material.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@immutable
abstract class CarePlanBlocEvent {
  const CarePlanBlocEvent();
}

class CarePlanInitializeEvent extends CarePlanBlocEvent {
  const CarePlanInitializeEvent({
    required this.whenPeriod,
    required this.users,
  });

  final PlanWhenPeriod whenPeriod;
  final List<UserModel> users;
}

class TimePeriodChangeEvent extends CarePlanBlocEvent {
  const TimePeriodChangeEvent(this.whenPeriod);
  final PlanWhenPeriod whenPeriod;
}

class MeasurementTypeChangeEvent extends CarePlanBlocEvent {
  const MeasurementTypeChangeEvent(
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
