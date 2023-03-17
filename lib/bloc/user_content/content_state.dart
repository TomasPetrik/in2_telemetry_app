import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'content_state.freezed.dart';

@freezed
class ContentState with _$ContentState {
  const factory ContentState.initial() = _Initial;
  const factory ContentState.unauthenticated() = _NoUser;
  const factory ContentState.onAppearanceChanged(ThemeMode newThemeMode) =
      _AppearanceChanged;
  const factory ContentState.onUserAdded(UserAccount userAccount) = _UserAdded;
  const factory ContentState.activeMode(Key key) = _ActiveMode;
}
