import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/manual.pdf'),
    );
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            top: Dimensions.appBarHeight,
            child: PdfViewPinch(
              controller: pdfController,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: localization.manual_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
