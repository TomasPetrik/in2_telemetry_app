import 'package:equatable/equatable.dart';
import 'package:scalesoft_app/model/user_account.dart';

abstract class UserContentEvent extends Equatable {
  const UserContentEvent();
  @override
  List<Object?> get props => [];
}

class CheckLastLoggedUserContentEvent extends UserContentEvent {
  const CheckLastLoggedUserContentEvent();
  @override
  List<Object?> get props => [];
}

class SwitchUserContentEvent extends UserContentEvent {
  final UserAccount userAccount;

  const SwitchUserContentEvent({required this.userAccount});

  @override
  List<Object?> get props => [userAccount];
}

class SwitchAllUsersContentEvent extends UserContentEvent {
  const SwitchAllUsersContentEvent();

  @override
  List<Object?> get props => [];
}

class SwitchNoUserContentEvent extends UserContentEvent {
  const SwitchNoUserContentEvent();

  @override
  List<Object?> get props => [];
}
