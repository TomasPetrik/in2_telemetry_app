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
  });

  @override
  Widget build(BuildContext context) {
    final AccountDbProvider accountDbProvider = getIt<AccountDbProvider>();
    return Column(
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
                style: ScaleTextStyles.textAccent.apply(color: Theme.of(context).colorScheme.onSecondary),
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
        Gaps.gap24,
        ...accountDbProvider
            .getHospitalUsers()
            .entries
            .map(
              (hospital) => Padding(
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
                      Navigator.of(context).pop(
                        UserSelection(
                          action: SwitchUserAction.selectedHospital,
                          selectedHospital: hospital.key,
                          hospitalUsers: hospital.value,
                        ),
                      );
                    }
                  },
                  hasNavigationIcon: hospital.value.length > 1,
                ),
              ),
            )
            .toList(),
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
    );
  }
}
