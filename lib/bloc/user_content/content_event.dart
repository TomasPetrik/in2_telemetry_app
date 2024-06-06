import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/user_model.dart';

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
  final int userId;

  const SwitchUserContentEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class OnUserAddedContentEvent extends ContentEvent {
  final UserModel userAccount;

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

class OnDaylightAppearanceChangedContentEvent extends ContentEvent {
  const OnDaylightAppearanceChangedContentEvent(
    this.originalLocation,
  );

  final String originalLocation;

  @override
  List<Object?> get props => [originalLocation];
}

class SwitchNoUserContentEvent extends ContentEvent {
  const SwitchNoUserContentEvent();

  @override
  List<Object?> get props => [];
}

class StopWatchDog extends ContentEvent {
  const StopWatchDog();

  @override
  List<Object?> get props => [];
}
