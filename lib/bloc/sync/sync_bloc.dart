import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final AccountDbProvider _accountDbProvider;
  final SyncService _syncService;
  final Session _session;

  SyncBloc(
    this._accountDbProvider,
    this._syncService,
    this._session,
  ) : super(const SyncState.none()) {
    on<SyncEvent>((event, emit) async {
      await event.when(
        init: () async {
          if (state == const SyncState.inProgress()) {
            return;
          }

          final syncState = await _session.detectSyncState();

          if (syncState != const SyncState.synced()) {
            emit(syncState);
          } else {
            emit(const SyncState.none());
          }
        },
        syncAll: () async {
          emit(const SyncState.inProgress());

          await _syncService.syncResults();

          await _syncService.syncAllData();

          final currentSyncState = await _session.detectSyncState();
          emit(currentSyncState);

          if (currentSyncState == const SyncState.synced()) {
            await Future.delayed(const Duration(seconds: 2));
            emit(const SyncState.none());
          }
        },
        syncResults: () async {
          emit(const SyncState.inProgress());

          await _syncService.syncResults();

          final currentSyncState = await _session.detectSyncState();
          emit(currentSyncState);

          if (currentSyncState == const SyncState.synced()) {
            await Future.delayed(const Duration(seconds: 2));
            emit(const SyncState.none());
          }
        },
        userSessionExpired: (String refreshToken) async {
          await _accountDbProvider.setExpiredUserByToken(refreshToken);

          emit(await _session.detectSyncState());
        },
        resolveUpdatedUserPlan: (CarePlanContract carePlanToUpdate) async {
          final userAccount = _accountDbProvider.get(carePlanToUpdate.userId!);
          if (userAccount == null) return;

          final carePlan = userAccount.carePlans
              ?.firstWhere((userPlan) => userPlan.id == carePlanToUpdate.id);
          carePlan?.wasChanged = false;

          _accountDbProvider.save(userAccount);

          final syncState = await _session.detectSyncState();

          if (syncState != const SyncState.synced()) {
            emit(syncState);
          } else {
            emit(const SyncState.none());
          }
        },
        removeOfflineResult: (MeasurementDataContract measurementResult) async {
          await _syncService.removeOfflineResult(measurementResult);
          final syncState = await _session.detectSyncState();

          if (syncState != const SyncState.synced()) {
            emit(syncState);
          } else {
            emit(const SyncState.none());
          }
        },
      );
    });
  }
}
