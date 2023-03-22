import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'chart_bloc_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class ChartBlocState with _$ChartBlocState {
  const factory ChartBlocState({
    List<CalendarMonth>? months,
    int? currentMonth,
    int? currentYear,
    PageController? controller,
    bool? isCurrentMonth,
    int? currentMonthIndex,
    List<DrawableRoot>? svgDrawables,
  }) = _CalendarBlocState;
}
