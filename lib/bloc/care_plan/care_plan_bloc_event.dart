import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';

@immutable
abstract class CarePlanBlocEvent {
  const CarePlanBlocEvent();
}

class CarePlanInitializeEvent extends CarePlanBlocEvent {
  const CarePlanInitializeEvent();
}

class CarePlanTimePeriodEvent extends CarePlanBlocEvent {
  const CarePlanTimePeriodEvent(this.periodTime);
  final PeriodType periodTime;
}
