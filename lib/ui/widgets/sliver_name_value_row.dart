import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class SliverNameValueRow extends StatelessWidget {
  const SliverNameValueRow({
    super.key,
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: Paddings.horizontal16,
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: ScaleTextStyles.text,
            ),
            Text(
              value,
              style: ScaleTextStyles.text,
            ),
          ],
        ),
      ),
    );
  }
}
