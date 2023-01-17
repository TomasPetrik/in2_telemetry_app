import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc_event.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/appearance_item.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = getIt<SettingsBloc>();
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
                      MediaQuery.of(context).viewPadding.top +
                          Constants.appBarHeight,
                    ),
                    Gaps.gap16,
                    Padding(
                      padding: Paddings.horizontal16,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.locale
                                          .configuration_screen_auto_mode_title,
                                      style: ScaleTextStyles.textAccent,
                                    ),
                                    Gaps.gap6,
                                    Text(
                                      context.locale
                                          .configuration_screen_auto_mode_desc,
                                      style: ScaleTextStyles.label.apply(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                onChanged: (bool isDarkMode) async {},
                                value: false,
                              ),
                            ],
                          ),
                          Gaps.gap24,
                          AppearanceItem(
                            itemType: AppearanceItemType.light,
                            isSelected:
                                settingsBloc.state.themeMode == ThemeMode.light,
                            onSelected: () {
                              settingsBloc.add(
                                SettingsChangeThemeEvent(
                                  newThemeMode: ThemeMode.light,
                                ),
                              );
                            },
                          ),
                          Gaps.gap24,
                          AppearanceItem(
                            itemType: AppearanceItemType.dark,
                            isSelected:
                                settingsBloc.state.themeMode == ThemeMode.dark,
                            onSelected: () {
                              settingsBloc.add(
                                SettingsChangeThemeEvent(
                                  newThemeMode: ThemeMode.dark,
                                ),
                              );
                            },
                          )
                        ],
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
