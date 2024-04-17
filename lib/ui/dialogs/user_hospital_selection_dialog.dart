import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/image_widget.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class UserHospitalSelectionDialog extends StatelessWidget {
  const UserHospitalSelectionDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserCubitState>(
      builder: (BuildContext context, UserCubitState state) {
        final users = state.allUsers;

        final hospitalUserEntries = users.groupListsBy<Hospital>((user) => user.hospital).entries.toList();
        final supportMultiUser = users.length > 1 || users.any((x) => x.representedPeople.isNotEmpty);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(RadiusSize.radius16),
              topRight: Radius.circular(RadiusSize.radius16),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Gaps.gap34,
                Padding(
                  padding: Paddings.horizontal16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        localization.hospital_selection_dialog_measurement_for,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop(
                            UserSelection(
                              action: SwitchUserAction.addUserAccount,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (supportMultiUser == true) ...[
                  Gaps.gap24,
                  Padding(
                    padding: Paddings.horizontal16,
                    child: SettingsItem(
                      label: localization.common_all_accounts,
                      subLabel: '${hospitalUserEntries.first.value[0].fullName}'
                          ' ${users.length > 1 ? localization.common_plus_n_others(users.length - 1) : ''}',
                      iconWidget: Padding(
                        padding: Paddings.all8,
                        child: SvgPicture.asset(
                          'assets/icons/icon_hospitals.svg',
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(
                          UserSelection(
                            action: SwitchUserAction.selectedMultiUser,
                          ),
                        );
                      },
                      hasNavigationIcon: false,
                    ),
                  ),
                ],
                Gaps.gap24,
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final hospital = hospitalUserEntries[index];
                    final hasMultipleUsers = hospital.value.length > 1;
                    final hospitalRootUsers = hospital.value.where((x) => x.parentId == null).toList();

                    return Padding(
                      padding: Paddings.horizontal16,
                      child: SettingsItem(
                        iconBackground: ScaleColorsLight.content20,
                        label: hospital.key.title,
                        subLabel: '${hospital.value[0].fullName}'
                            ' ${hasMultipleUsers ? localization.common_plus_n_others(hospital.value.length - 1) : ''}',
                        iconWidget: Padding(
                          padding: Paddings.all8,
                          child: ImageWidget(hospital.key.iconPath),
                        ),
                        onTap: () {
                          if (!hasMultipleUsers) {
                            Navigator.of(context).pop(
                              UserSelection(
                                action: SwitchUserAction.selectedUser,
                                selectedUser: hospital.value[0],
                              ),
                            );
                          } else {
                            Navigator.of(context).pop(
                              UserSelection(
                                action: SwitchUserAction.selectedHospital,
                                selectedHospital: hospital.key,
                                hospitalUsers: hospitalRootUsers,
                              ),
                            );
                          }
                        },
                        hasNavigationIcon: hasMultipleUsers,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) {
                    return Gaps.gap24;
                  },
                  itemCount: hospitalUserEntries.length,
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
      bloc: getIt<UserCubit>(),
    );
  }
}
