import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@injectable
class CarePlanBloc extends Bloc<CarePlanBlocEvent, CarePlanBlocState> {
  final CarePlansRepository _carePlansRepository;
  final AccountDbProvider _accountDbProvider;
  final Session _session;

  CarePlanBloc(
    this._carePlansRepository,
    this._accountDbProvider,
    this._session,
  ) : super(CarePlanBlocState()) {
    on<CarePlanInitializeEvent>((event, emit) async {
      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: event.carePlans,
        reqCount: 1,
      );

      final measurements = CarePlanHelper.getMeasurements(
        event.carePlans,
        event.periodTime,
      );

      emit(
        CarePlanBlocState(
          currentCarePlans: event.carePlans,
          selectedPeriod: event.periodTime,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
        ),
      );
    });

    on<TimePeriodChangeEvent>((event, emit) {
      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: state.currentCarePlans!,
        reqCount: 1,
      );

      final measurements = CarePlanHelper.getMeasurements(
        state.currentCarePlans!,
        event.periodTime,
      );

      emit(
        state.copyWith(
          selectedPeriod: event.periodTime,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
        ),
      );
    });

    on<CurrentPlansChangeEvent>((event, emit) {
      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: event.carePlans,
        reqCount: 1,
      );

      final measurements = CarePlanHelper.getMeasurements(
        event.carePlans,
        state.selectedPeriod!,
      );

      emit(
        state.copyWith(
          currentCarePlans: event.carePlans,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
        ),
      );
    });

    on<ReloadCarePlansEvent>(
      (event, emit) async {
        final userAccount = event.userAccount;

        //load and assign care plans, fulfillment_evaluation
        final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
          patientMuid: userAccount.user.muid,
        );

        for (final carePlan in activeCarePlans.items) {
          final fulfillmentEvaluation =
              await _carePlansRepository.loadFulFillmentEvaluation(
            carePlanVersionId: carePlan.versionId,
          );
          carePlan.fulfillmentEvaluation = fulfillmentEvaluation;
        }

        userAccount.carePlans = activeCarePlans.items;
        if (userAccount.representedPeople?.isNotEmpty == true) {
          for (final UserAccount representedPerson
              in userAccount.representedPeople!) {
            final activeCarePlans =
                await _carePlansRepository.loadActiveCarePlans(
              patientMuid: representedPerson.user.muid,
            );

            for (final carePlan in activeCarePlans.items) {
              final fulfillmentEvaluation =
                  await _carePlansRepository.loadFulFillmentEvaluation(
                carePlanVersionId: carePlan.versionId,
              );
              carePlan.fulfillmentEvaluation = fulfillmentEvaluation;
            }

            representedPerson.carePlans = activeCarePlans.items;
          }
        }

        await _accountDbProvider.save(userAccount);
        _session.userAccount = userAccount;
        emit(state);
      },
    );
  }
}
