import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/configuration/hospitals_configuration.dart';
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart';
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/image_widget.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/ui/widgets/scale_search_bar.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class HospitalSelectionDialog extends StatelessWidget {
  const HospitalSelectionDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<HospitalSearchCubit>();

    return BlocBuilder<AppSettingsBloc, AppSetting?>(
      bloc: getIt<AppSettingsBloc>()..add(const AppSettingsBlocEvent.initSettings()),
      builder: (context, settings) {
        if (settings == null) {
          return const LoadingIndicator();
        }

        final hospitals = settings.enableStagingHospitals
            ? HospitalsConfiguration.hospitals
            : HospitalsConfiguration.hospitals.where((x) => !x.isStaging).toList();

        TextEditingController searchController = TextEditingController();

        searchController.addListener(() {
          cubit.search(
            criteria: searchController.text,
            initialList: hospitals,
          );
        });

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(RadiusSize.radius16),
              topRight: Radius.circular(RadiusSize.radius16),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Gaps.gap34,
                Padding(
                  padding: Paddings.horizontal16,
                  child: ScaleSearchBar(
                    searchHint: localization.hospital_selector_search_for_account,
                    searchController: searchController,
                    onBack: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Gaps.gap24,
                BlocBuilder<HospitalSearchCubit, HospitalSearchState>(
                  bloc: cubit,
                  builder: (context, state) {
                    final list = state.when(
                      initial: () => hospitals,
                      result: ((hospitals) => hospitals.toList()),
                    );

                    return Column(
                      children: [
                        ...list.mapIndexed((index, hospital) {
                          final padding =
                              index == 0 ? Paddings.horizontal16 : Paddings.horizontal16.add(Paddings.top24);

                          return Padding(
                            padding: padding,
                            child: SettingsItem(
                              iconBackground: ScaleColorsLight.content20,
                              label: hospital.title,
                              iconWidget: Padding(
                                padding: Paddings.all8,
                                child: ImageWidget(hospital.iconPath),
                              ),
                              onTap: () {
                                Navigator.of(context).pop(
                                  UserSelection(
                                    action: SwitchUserAction.addUserAccount,
                                    selectedHospital: hospital,
                                  ),
                                );
                              },
                              hasNavigationIcon: false,
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
                Gaps.gap24,
                Padding(
                  padding: Paddings.horizontal16,
                  child: HighlightedElevatedButton(
                    label: localization.common_close,
                    buttonType: ButtonType.secondary,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Gaps.gap48,
              ],
            ),
          ),
        );
      },
    );
  }
}
