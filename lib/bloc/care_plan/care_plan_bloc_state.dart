import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

part 'care_plan_bloc_state.freezed.dart';

@freezed
class CarePlanBlocState with _$CarePlanBlocState {
  const CarePlanBlocState._();


  factory CarePlanBlocState({
    WhenPeriod? selectedPeriod,
    List<CarePlan>? currentCarePlans,
    Measurement? nextMeasurement,
    List<Measurement>? measurements,
  }) = _HasData;
}
