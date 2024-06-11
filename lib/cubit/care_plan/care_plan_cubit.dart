import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit_state.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

class CarePlanCubit extends Cubit<CarePlanCubitState> {
  final CarePlanDbProvider _carePlanDbProvider = getIt<CarePlanDbProvider>();

  CarePlanCubit({
    CarePlanCubitState initialState = const CarePlanCubitState([]),
  }) : super(initialState);

  /// Loads care plans of user with the given [userId].
  /// Can be called multiple times.
  Future<void> init(int userId) async {
    final carePlans = await _carePlanDbProvider.getByUser(userId);

    emit(CarePlanCubitState(carePlans));
  }
}
