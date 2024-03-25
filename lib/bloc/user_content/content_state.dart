import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/user_model.dart';

part 'content_state.freezed.dart';

@freezed
class ContentState with _$ContentState {
  const factory ContentState.initial() = _Initial;
  const factory ContentState.unauthenticated() = _NoUser;
  const factory ContentState.onDaylightAppearanceChanged(
    String originalLocation,
  ) = _OnDaylightAppearanceChanged;
  const factory ContentState.onUserAdded(UserModel user) = _UserAdded;
  const factory ContentState.tryCompleteAuth(Uri uri) = _TryCompleteAuth;
  const factory ContentState.activeMode(Key key) = _ActiveMode;
}
