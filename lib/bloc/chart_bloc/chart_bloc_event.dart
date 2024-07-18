import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

part 'chart_bloc_event.freezed.dart';

@freezed
class ChartBlocEvent with _$ChartBlocEvent {
  const factory ChartBlocEvent.init(
    BuildContext context,
    DateTime initDt,
    int userId,
    MeasurementType measurementType,
    Color iconColor,
  ) = _Init;
  const factory ChartBlocEvent.onPageChanged(int newPage) = _OnPageChanged;
  const factory ChartBlocEvent.goToPreviousMonth() = _GoToPreviousMonth;
  const factory ChartBlocEvent.goToNextMonth() = _GoToNextMonth;
}
