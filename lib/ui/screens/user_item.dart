import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/painters/user_item_painter.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';
import 'package:scalesoft_app/ui/widgets/user_item_shape.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.userAccount,
    this.userItemType,
    required this.hasNavigationIcon,
  });

  final UserAccount userAccount;
  final UserItemType? userItemType;
  final bool hasNavigationIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.horizontal16,
      child: Row(
        children: [
          if (userItemType == UserItemType.middle ||
              userItemType == UserItemType.last) ...[
            Gaps.gap16,
            SizedBox(
              height: 64,
              child: UserItemShape(userItemType: userItemType!),
            ),
          ],
          Expanded(
            child: SettingsItem(
              label: userAccount.user.fullName,
              hasNavigationIcon: hasNavigationIcon,
              iconWidget: Padding(
                padding: Paddings.all8,
                child: Text(
                  '${userAccount.user.firstNames[0][0]}${userAccount.user.lastNames[0][0]}',
                  style: ScaleTextStyles.title.apply(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
