import 'package:equatable/equatable.dart';
import 'package:scalesoft_app/model/user_account.dart';

abstract class SwitchContentEvent extends Equatable {
  const SwitchContentEvent();
  @override
  List<Object?> get props => [];
}

class CheckLastLoggedUserContentEvent extends SwitchContentEvent {
  const CheckLastLoggedUserContentEvent();
  @override
  List<Object?> get props => [];
}

class SwitchUserContentEvent extends SwitchContentEvent {
  final UserAccount userAccount;

  const SwitchUserContentEvent({required this.userAccount});

  @override
  List<Object?> get props => [userAccount];
}

class OnUserAddedContentEvent extends SwitchContentEvent {
  final UserAccount userAccount;

  const OnUserAddedContentEvent({required this.userAccount});

  @override
  List<Object?> get props => [userAccount];
}

class OnAppearanceChangedContentEvent extends SwitchContentEvent {
  const OnAppearanceChangedContentEvent();

  @override
  List<Object?> get props => [];
}

class SwitchAllUsersContentEvent extends SwitchContentEvent {
  const SwitchAllUsersContentEvent();

  @override
  List<Object?> get props => [];
}

class SwitchNoUserContentEvent extends SwitchContentEvent {
  const SwitchNoUserContentEvent();

  @override
  List<Object?> get props => [];
}
