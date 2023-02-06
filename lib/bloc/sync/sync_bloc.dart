import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';

@singleton
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final AccountDbProvider _accountDbProvider;
  final CarePlansRepository _carePlansRepository;

  SyncBloc(
    this._pendingResultsDbProvider,
    this._accountDbProvider,
    this._carePlansRepository,
  ) : super(const SyncState.none()) {
    on<SyncEvent>((event, emit) async {
      await event.when(
        init: () {
          if (state == const SyncState.inProgress()) {
            return;
          }

          final manualMeasurements = _pendingResultsDbProvider.getAll();
          if (manualMeasurements?.isNotEmpty == true) {
            emit(const SyncState.failed());
          } else {
            emit(const SyncState.none());
          }
        },
        sync: () async {
          try {
            final manualMeasurements = _pendingResultsDbProvider.getAll();

            if (manualMeasurements?.isNotEmpty == true) {
              emit(const SyncState.inProgress());
              for (final manualMeasurement in manualMeasurements!) {
                final assignedAccount =
                    _accountDbProvider.get(manualMeasurement.patientMuid!);
                await _carePlansRepository.sendManualMeasurement(
                  userAccount: assignedAccount!,
                  manualMeasurement: manualMeasurement,
                );
                await _pendingResultsDbProvider.remove(manualMeasurement);
              }
              emit(const SyncState.synced());
              await Future.delayed(const Duration(seconds: 2));
              emit(const SyncState.none());
            } else {
              emit(const SyncState.none());
            }
          } catch (_) {
            emit(const SyncState.failed());
          }
        },
        errorComm: () {
          if (state == const SyncState.inProgress()) {
            emit(const SyncState.failed());
          }
        },
      );
    });
  }
}
