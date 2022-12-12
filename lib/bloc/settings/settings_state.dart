import 'package:equatable/equatable.dart';
import 'package:scalesoft_app/model/app_settings.dart';

class SettingsState extends Equatable {
  final AppSettings appSettings;

  const SettingsState({required this.appSettings});

  @override
  List<Object?> get props => [appSettings];

  SettingsState copyWith({
    AppSettings? appSettings,
    String? secret,
  }) {
    return SettingsState(
      appSettings: appSettings ?? this.appSettings,
    );
  }
}
