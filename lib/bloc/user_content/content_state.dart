import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'content_state.freezed.dart';

@freezed
class ContentState with _$ContentState {
  const factory ContentState.initial() = _Initial;
  const factory ContentState.unauthenticated() = _NoUser;
  const factory ContentState.onAppearanceChanged() = _AppearanceChanged;
  const factory ContentState.onUserAdded(UserAccount userAccount) = _UserAdded;
  const factory ContentState.activeSingleUser(UserAccount userAccount) = _ActiveSingleUser;
  const factory ContentState.activeAllUsers() = _ActiveAllUsers;
}
