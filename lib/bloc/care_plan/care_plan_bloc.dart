import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';

@injectable
class CarePlanBloc extends Bloc<CarePlanBlocEvent, CarePlanBlocState> {
  CarePlanBloc() : super(const CarePlanBlocState()) {
    on<CarePlanBlocEvent>((event, emit) async {
      //setLoadingState(LoadingState.loading);
      try {
        if (event is CarePlanInitializeEvent) {
          // final newProducts = await _newProductsRepository.getNewProducts(SortType.apiDefault);
          emit.call(
            const CarePlanBlocState(
              selectedPeriod: PeriodType.today,
            ),
          );
        }
      } catch (e) {
        //defaultErrorHandler(error: e, event: event, isInitializeEvent: event is NewProductsPageBlocInitializeEvent);
      }
      // setLoadingState(LoadingState.loaded);
    });
    on<CarePlanTimePeriodEvent>((event, emit) {
      emit(
        state.cloneWith(
          selectedPeriod: event.periodTime,
        ),
      );
    });
  }
}
