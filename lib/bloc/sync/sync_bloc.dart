import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/services/sync_service.dart';

@singleton
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final AccountDbProvider _accountDbProvider;
  final CarePlansRepository _carePlansRepository;
  final SyncService _syncService;

  SyncBloc(
    this._pendingResultsDbProvider,
    this._accountDbProvider,
    this._carePlansRepository,
    this._syncService,
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
        syncAll: (userAccounts) async {
          emit(const SyncState.inProgress());
          for (final userAccount in userAccounts) {
            await _syncService.loadUserData(userAccount);
            await _accountDbProvider.save(userAccount);
          }
          emit(const SyncState.synced());
          await Future.delayed(const Duration(seconds: 2));
          emit(const SyncState.none());
        },
        syncResults: () async {
          try {
            final pendingMeasurements = _pendingResultsDbProvider.getAll();

            if (pendingMeasurements?.isNotEmpty == true) {
              emit(const SyncState.inProgress());
              final Set<String?> usersIds = {};
              for (final pendingMeasurement in pendingMeasurements!) {
                final assignedAccount =
                    _accountDbProvider.get(pendingMeasurement.patientMuid!);
                //TODO.. distinguish if it was manual or regular measurement by sourceDevice presence
                await _carePlansRepository.sendManualMeasurement(
                  userAccount: assignedAccount!,
                  manualMeasurement: pendingMeasurement,
                );
                await _pendingResultsDbProvider.remove(pendingMeasurement);
                usersIds.add(pendingMeasurement.patientMuid);
              }
              //reload users results
              for (final userId in usersIds) {
                if (userId != null) {
                  final userAccount = _accountDbProvider.get(userId);
                  await _syncService.loadMeasurementResults(userAccount!);
                  await _syncService.loadFulfillmentEvaluation(userAccount);
                  await _accountDbProvider.save(userAccount);
                }
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
