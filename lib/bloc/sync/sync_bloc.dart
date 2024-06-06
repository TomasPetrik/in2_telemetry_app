import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';

@singleton
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final UserDbProvider _userDbProvider;
  final SyncService _syncService;
  final UserCubit _session;
  final CarePlanDbProvider _carePlanDbProvider;

  SyncBloc(
    this._userDbProvider,
    this._syncService,
    this._session,
    this._carePlanDbProvider,
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
          await _userDbProvider.setExpiredByRefreshToken(refreshToken);

          emit(await _session.detectSyncState());
        },
        resolveUpdatedUserPlan: (int carePlanId) async {
          await _carePlanDbProvider.resolveUpdatedCarePlan(carePlanId);

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
