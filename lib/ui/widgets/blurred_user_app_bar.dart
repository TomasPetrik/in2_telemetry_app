import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/widgets/blurred_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/user_app_bar.dart';

class BlurredUserAppBar extends StatelessWidget {
  const BlurredUserAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const BlurredAppBar(
      child: UserAppBar(),
    );
  }
}
