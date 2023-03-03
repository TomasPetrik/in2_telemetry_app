import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/user_account.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();
  @override
  List<Object?> get props => [];
}

class CheckLastLoggedUserContentEvent extends ContentEvent {
  const CheckLastLoggedUserContentEvent();
  @override
  List<Object?> get props => [];
}

class SwitchMultiUserContentEvent extends ContentEvent {
  const SwitchMultiUserContentEvent();

  @override
  List<Object?> get props => [];
}

class SwitchUserContentEvent extends ContentEvent {
  final UserAccount userAccount;

  const SwitchUserContentEvent({required this.userAccount});

  @override
  List<Object?> get props => [userAccount];
}

class OnUserAddedContentEvent extends ContentEvent {
  final UserAccount userAccount;

  const OnUserAddedContentEvent({required this.userAccount});

  @override
  List<Object?> get props => [userAccount];
}

class OnAppearanceChangedContentEvent extends ContentEvent {
  const OnAppearanceChangedContentEvent(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode.index];
}

class SwitchAllUsersContentEvent extends ContentEvent {
  const SwitchAllUsersContentEvent();

  @override
  List<Object?> get props => [];
}

class SwitchNoUserContentEvent extends ContentEvent {
  const SwitchNoUserContentEvent();

  @override
  List<Object?> get props => [];
}
