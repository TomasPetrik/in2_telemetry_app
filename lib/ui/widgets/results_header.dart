import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    super.key,
    required this.whenPeriod,
    required this.openTimeSelector,
  });

  final ResultsWhenPeriod whenPeriod;
  final Function openTimeSelector;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.locale.results_screen_results_title,
          style: ScaleTextStyles.textAccent
              .apply(color: Theme.of(context).colorScheme.onSecondary),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            openTimeSelector.call();
          },
          child: Text(
            context.locale.common_measurement_times(whenPeriod.name),
            style: ScaleTextStyles.text.apply(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
