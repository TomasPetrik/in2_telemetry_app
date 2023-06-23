import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_day.dart';
import 'package:scalesoft_app/bloc/calendar_footer/calendar_footer_event.dart';

@singleton
class CalendarFooterBloc
    extends Bloc<CalendarFooterEvent, CalendarFooterState> {
  CalendarFooterBloc() : super(CalendarFooterState()) {
    on<CalendarFooterEvent>((event, emit) async {
      await event.when(
        selectDay: (CalendarDay? calendarDay) async {
          await Future.delayed(const Duration(seconds: 1));
          emit(CalendarFooterState(selectedDay: calendarDay));
        },
      );
    });
  }
}
