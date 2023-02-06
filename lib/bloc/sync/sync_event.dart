import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_event.freezed.dart';

@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.init() = _Init;
  const factory SyncEvent.sync() = _Sync;
  const factory SyncEvent.errorComm() = _ErrorComm;
}
