import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart';
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';
import 'package:scalesoft_app/utils/constants.dart';

class HospitalSelectionDialog extends StatelessWidget {
  const HospitalSelectionDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final cubit = getIt<HospitalSearchCubit>();

    searchController.addListener(() {
      cubit.search(
        criteria: searchController.text,
        initialList: Constants.hospitals,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Gaps.gap34,
          Padding(
            padding: Paddings.horizontal16,
            child: SearchBar(
              hintText: translactions.hospital_selector_search_for_account,
              controller: searchController,
              /*
              onBack: () {
                Navigator.of(context).pop();
              },
              */
            ),
          ),
          Gaps.gap24,
          BlocBuilder<HospitalSearchCubit, HospitalSearchState>(
            bloc: cubit,
            builder: (context, state) {
              final list = state.when(
                initial: () => Constants.hospitals,
                result: ((hospitals) => hospitals.toList()),
              );

              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final hospital = list[index];
                  return Padding(
                    padding: Paddings.horizontal16,
                    child: SettingsItem(
                      label: hospital.title,
                      iconWidget: Padding(
                        padding: Paddings.all8,
                        child: SvgPicture.asset(
                          hospital.iconPath,
                          color: Theme.of(context).hintColor,
                        ),
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
                },
                separatorBuilder: (_, __) {
                  return Gaps.gap24;
                },
                itemCount: list.length,
              );
            },
          ),
          Gaps.gap24,
          Padding(
            padding: Paddings.horizontal16,
            child: HighlightedElevatedButton(
              label: translactions.common_close,
              buttonType: ButtonType.secondary,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Gaps.gap48,
        ],
      ),
    );
  }
}
