import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          context.locale.not_found_screen_title,
        ),
      ),
    );
  }
}
