import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/manual.pdf'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.manual_screen_title),
      ),
      body: PdfViewPinch(
        controller: pdfController,
      ),
    );
  }
}
