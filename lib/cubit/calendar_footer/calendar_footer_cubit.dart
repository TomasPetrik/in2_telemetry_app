import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_day.dart';

@singleton
class CalendarFooterCubit extends Cubit<CalendarFooterState> {
  CalendarFooterCubit() : super(CalendarFooterState());

  void selectDay(CalendarDay? calendarDay) {
    emit(CalendarFooterState(selectedDay: calendarDay));
  }
}
