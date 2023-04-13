import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';

part 'chart_bloc_event.freezed.dart';

@freezed
class ChartBlocEvent with _$ChartBlocEvent {
  const factory ChartBlocEvent.init(
    BuildContext context,
    DateTime initDt,
    List<CarePlan> carePlans,
    Color iconColor,
  ) = _Init;
  const factory ChartBlocEvent.onPageChanged(int newPage) = _OnPageChanged;
  const factory ChartBlocEvent.goToPreviousMonth() = _GoToPreviousMonth;
  const factory ChartBlocEvent.goToNextMonth() = _GoToNextMonth;
}
