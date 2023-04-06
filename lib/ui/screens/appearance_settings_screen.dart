import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/appearance_item.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/switch_row.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = getIt<AppSettingsBloc>()
      ..add(const AppSettingsBlocEvent.initSettings());
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              key: UniqueKey(),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(
                      MediaQuery.of(context).viewPadding.top + Dimensions.appBarHeight,
                    ),
                    Gaps.gap16,
                    Padding(
                      padding: Paddings.horizontal16,
                      child: BlocBuilder<AppSettingsBloc, AppSettings>(
                        bloc: settingsBloc,
                        builder: (context, state) {
                          return Column(
                            children: [
                              SwitchRow.titleAndLabel(
                                title: context.locale
                                    .configuration_screen_auto_mode_title,
                                label: context
                                    .locale.configuration_screen_auto_mode_desc,
                                defaultValue:
                                    settingsBloc.state.autosetAppearance ==
                                        true,
                                onChanged: (turnedOn) {
                                  settingsBloc.add(
                                    AppSettingsBlocEvent.setAutoAppearance(
                                      turnedOn,
                                    ),
                                  );
                                },
                              ),
                              state.autosetAppearance == true
                                  ? const SizedBox.shrink()
                                  : Column(
                                      children: [
                                        Gaps.gap24,
                                        AppearanceItem(
                                          itemType: AppearanceItemType.light,
                                          isSelected: settingsBloc.state
                                                  .themeModeLocal.themeMode ==
                                              ThemeMode.light,
                                          onSelected: () {
                                            settingsBloc.add(
                                              const AppSettingsBlocEvent
                                                  .themeChanged(
                                                ThemeMode.light,
                                              ),
                                            );
                                          },
                                        ),
                                        Gaps.gap24,
                                        AppearanceItem(
                                          itemType: AppearanceItemType.dark,
                                          isSelected: settingsBloc.state
                                                  .themeModeLocal.themeMode ==
                                              ThemeMode.dark,
                                          onSelected: () {
                                            settingsBloc.add(
                                              const AppSettingsBlocEvent
                                                  .themeChanged(
                                                ThemeMode.dark,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: context.locale.appearance_screen_title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
