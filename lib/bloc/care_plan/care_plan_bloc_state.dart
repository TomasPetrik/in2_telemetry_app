import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';

@immutable
class CarePlanBlocState {
  const CarePlanBlocState({
    this.selectedPeriod,
  });
  final PeriodType? selectedPeriod;

  CarePlanBlocState cloneWith({
    final PeriodType? selectedPeriod,
  }) =>
      CarePlanBlocState(
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      );
}
