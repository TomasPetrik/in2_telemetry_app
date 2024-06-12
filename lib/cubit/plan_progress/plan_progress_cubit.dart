import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

part 'plan_progress_state.dart';

@injectable
class PlanProgressCubit extends Cubit<PlanProgressState> {
  final MeasurementsDbProvider _measurementDbProvider;

  PlanProgressCubit(this._measurementDbProvider) : super(PlanProgressState.initial());

  Future<void> setCarePlan(CarePlan plan) async {
    final offlineMeasurements = await _measurementDbProvider.getByUser(plan.targetUserId, ofType: plan.activity.measurementType);

    final progress = EvaluationPlanHelper.getProgressFromFullPlanEvaluation(
      carePlan: plan,
      offlineResults: offlineMeasurements,
    );

    emit(PlanProgressState(progress));
  }
}


