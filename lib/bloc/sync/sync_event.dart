import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'sync_event.freezed.dart';

@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.init() = _Init;
  const factory SyncEvent.syncAll(List<UserAccount> userAccounts) = _SyncAll;
  const factory SyncEvent.syncResults() = _SyncResults;
  const factory SyncEvent.errorComm() = _ErrorComm;
}
