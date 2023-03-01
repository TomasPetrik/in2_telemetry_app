import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class UserHospitalSelectionDialog extends StatelessWidget {
  const UserHospitalSelectionDialog({
    super.key,
    this.supportMultiUser,
  });

  final bool? supportMultiUser;

  @override
  Widget build(BuildContext context) {
    final AccountDbProvider accountDbProvider = getIt<AccountDbProvider>();
    final hospitalUserEntries = accountDbProvider.getHospitalUsersMap().entries;
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
                    context.locale.hospital_selection_dialog_measurement_for,
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
                  )
                ],
              ),
            ),
            if (supportMultiUser == true) ...[
              Gaps.gap24,
              Padding(
                padding: Paddings.horizontal16,
                child: SettingsItem(
                  label: context.locale.common_all_accounts,
                  subLabel:
                      '${hospitalUserEntries.first.value[0].user.fullName}'
                      ' ${hospitalUserEntries.first.value.length > 1 ? context.locale.common_plus_n_others(hospitalUserEntries.first.value.length - 1) : ''}',
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
                final hospital = hospitalUserEntries.toList()[index];
                return Padding(
                  padding: Paddings.horizontal16,
                  child: SettingsItem(
                    label: hospital.key.title,
                    subLabel: '${hospital.value[0].user.fullName}'
                        ' ${hospital.value.length > 1 ? context.locale.common_plus_n_others(hospital.value.length - 1) : ''}',
                    iconWidget: Padding(
                      padding: Paddings.all8,
                      child: SvgPicture.asset(
                        hospital.key.iconPath,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    onTap: () {
                      if (hospital.value.length == 1) {
                        Navigator.of(context).pop(
                          UserSelection(
                            action: SwitchUserAction.selectedUser,
                            selectedUser: hospital.value[0],
                          ),
                        );
                      } else {
                        final hospitalUsers = accountDbProvider
                            .getRootUsersFromHospital(hospital.key);
                        Navigator.of(context).pop(
                          UserSelection(
                            action: SwitchUserAction.selectedHospital,
                            selectedHospital: hospital.key,
                            hospitalUsers: hospitalUsers,
                          ),
                        );
                      }
                    },
                    hasNavigationIcon: hospital.value.length > 1,
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
                label: context.locale.common_close,
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
  }
}
