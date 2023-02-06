import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.none() = _None;
  const factory SyncState.inProgress() = _InProgress;
  const factory SyncState.synced() = _Synced;
  const factory SyncState.failed() = _Failed;
}
