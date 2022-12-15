import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_web_state.freezed.dart';

@freezed
class AuthWebState with _$AuthWebState {
  const factory AuthWebState.loading() = _Loading;
  const factory AuthWebState.loaded() = _Loaded;
}
