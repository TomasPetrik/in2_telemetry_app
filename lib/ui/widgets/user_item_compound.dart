import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/ui/painters/user_item_painter.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/user_item.dart';
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
  });

  final UserModel userAccount;
  final Function(UserModel) onUserSelected;
  final UserItemCompoundType userItemCompoundType;

  int get _itemCount {
    return userAccount.representedPeople.isNotEmpty == true
        ? userAccount.representedPeople.length + 1
        : 1;
  }

  List<UserModel> _getUserAccounts() {
    final List<UserModel> userAccounts = [];

    userAccounts.add(userAccount);

    if (userAccount.representedPeople.isNotEmpty == true) {
      userAccounts.addAll(userAccount.representedPeople);
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
                showWarning: userAccount.problem != null,
                user: userAccount,
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
