import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/painters/user_item_painter.dart';
import 'package:scalesoft_app/ui/screens/user_item.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/user_item_shape.dart';

enum UserItemCompoundType {
  bottomSheet,
  settings,
}

class UserItemCompound extends StatelessWidget {
  const UserItemCompound({
    super.key,
    required this.userAccount,
    required this.onUserSelected,
    required this.userItemCompoundType,
    this.showWarning,
  });

  final UserAccount userAccount;
  final Function(UserAccount) onUserSelected;
  final UserItemCompoundType userItemCompoundType;
  final bool? showWarning;

  int get _itemCount {
    return userAccount.representedPeople?.isNotEmpty == true
        ? userAccount.representedPeople!.length + 1
        : 1;
  }

  List<UserAccount> _getUserAccounts() {
    final List<UserAccount> userAccounts = [];

    userAccounts.add(userAccount);

    if (userAccount.representedPeople?.isNotEmpty == true) {
      userAccounts.addAll(userAccount.representedPeople!);
    }
    return userAccounts;
  }

  UserItemType? _getUserItemTypeByIndex(int index) {
    if (_itemCount > 1) {
      if (index == 0) {
        return UserItemType.top;
      } else if (index == _itemCount - 1) {
        return UserItemType.last;
      } else {
        return UserItemType.middle;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userAccounts = _getUserAccounts();
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 24,
          child: Padding(
            padding: Paddings.left32,
            child: UserItemShape(userItemType: UserItemType.top),
          ),
        );
      },
      itemBuilder: ((context, index) {
        final userAccount = userAccounts[index];

        return InkWell(
          onTap: () {
            onUserSelected.call(userAccount);
          },
          child: Stack(
            children: [
              UserItem(
                key: ValueKey(index),
                showWarning: showWarning,
                userAccount: userAccount,
                hasNavigationIcon:
                    userItemCompoundType == UserItemCompoundType.settings,
                userItemType: _getUserItemTypeByIndex(index),
              ),
            ],
          ),
        );
      }),
      itemCount: _itemCount,
    );
  }
}
