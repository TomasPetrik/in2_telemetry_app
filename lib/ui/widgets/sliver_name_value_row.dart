import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

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
              style: ScaleTextStyles.text
                  .apply(color: Theme.of(context).colorScheme.onPrimary),
            ),
            Text(
              value,
              style: ScaleTextStyles.text
                  .apply(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
