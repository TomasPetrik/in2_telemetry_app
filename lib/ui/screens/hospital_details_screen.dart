import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/screens/user_details_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({
    super.key,
    required this.hospital,
    required this.userAccounts,
  });

  final Hospital hospital;
  final List<UserAccount> userAccounts;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverGap(MediaQuery.of(context).viewPadding.top + Constants.appBarHeight),
              const SliverGap(Dimensions.padding24),
              ...userAccounts.map(
                (userAccount) => SliverPadding(
                  padding: Paddings.horizontal16,
                  sliver: SliverToBoxAdapter(
                    child: SettingsItem(
                      label: userAccount.user.fullName,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => UserDetailScreen(
                              userAccount: userAccount,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: hospital.title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
