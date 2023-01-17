import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/user_item_compound.dart';

class UserSelectionDialog extends StatelessWidget {
  const UserSelectionDialog({
    super.key,
    required this.hospital,
    required this.userAccounts,
  });

  final Hospital hospital;
  final List<UserAccount> userAccounts;

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Gaps.gap20,
                Text(
                  context.locale.user_selection_dialog_measurement_in_hospital(
                    hospital.title,
                  ),
                  style: ScaleTextStyles.textAccent
                      .apply(color: Theme.of(context).colorScheme.onSecondary),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(
                      UserSelection(action: SwitchUserAction.addUserAccount),
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
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final userAccount = userAccounts[index];
              return UserItemCompound(
                userAccount: userAccount,
                userItemCompoundType: UserItemCompoundType.bottomSheet,
                onUserSelected: (userAccount) {
                  Navigator.of(context).pop(
                    UserSelection(
                      action: SwitchUserAction.selectedUser,
                      selectedUser: userAccount,
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) {
              return Gaps.gap24;
            },
            itemCount: userAccounts.length,
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
    );
  }
}
