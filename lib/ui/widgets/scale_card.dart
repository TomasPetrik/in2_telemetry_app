import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

class ScaleCard extends StatelessWidget {
  const ScaleCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadii.radius16,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 24,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: child,
    );
  }
}
