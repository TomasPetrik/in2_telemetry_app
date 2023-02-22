import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/widgets/blured_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/user_app_bar.dart';

class BluredUserAppBar extends StatelessWidget {
  const BluredUserAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const BluredAppBar(
      child: UserAppBar(),
    );
  }
}
