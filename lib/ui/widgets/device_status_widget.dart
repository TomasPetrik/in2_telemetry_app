import 'package:flutter/cupertino.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';

class DeviceStatusWidget extends StatelessWidget {
  const DeviceStatusWidget({
    super.key,
    required this.title,
    required this.icon,
    this.isRotating,
  });

  final String title;
  final Widget? icon;
  final bool? isRotating;

  @override
  Widget build(BuildContext context) {
    return ScaleCard(
      child: Row(
        children: [
          if (icon != null) ...{
            isRotating == true ? RotatingIcon(child: icon!) : icon!
          },
          Text(
            title,
          ),
        ],
      ),
    );
  }
}
