import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'user_content_state.freezed.dart';

@freezed
class UserContentState with _$UserContentState {
  const factory UserContentState.initial() = _Initial;
  const factory UserContentState.noUser() = _NoUser;
  const factory UserContentState.activeSingleUser(UserAccount userAccount) = _ActiveSingleUser;
  const factory UserContentState.activeAllUsers() = _ActiveAllUsers;
}
