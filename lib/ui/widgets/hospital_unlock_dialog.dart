import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class HospitalUnlockDialog extends StatefulWidget {
  const HospitalUnlockDialog({super.key});

  @override
  State<StatefulWidget> createState() => HospitalUnlockDialogState();
}

class HospitalUnlockDialogState extends State<HospitalUnlockDialog> {
  final codeController = TextEditingController();

  bool isInvalid = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Odemknout testovací prostředí?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Pro odemknutí testovacích prostředí zadejte aktivační kód."),
          TextField(
            decoration: const InputDecoration(hintText: "Kód"),
            controller: codeController,
            onChanged: (_) {
              if (isInvalid) {
                setState(() {
                  isInvalid = false;
                });
              }
            },
            style: ScaleTextStyles.text.apply(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          if (isInvalid)
            Text(
              "Zadaný kód není platný.",
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Zrušit"),
        ),
        TextButton(
          onPressed: verifyCode,
          child: const Text("Povolit"),
        ),
      ],
    );
  }

  void verifyCode() {
    var bytes = utf8.encode(codeController.text);
    var digest = sha1.convert(bytes);

    final matchesHash = digest.toString().toLowerCase() == ConfigurationConstants.stagingUnlockHash.toLowerCase();

    if (matchesHash) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      isInvalid = true;
    });
  }
}
