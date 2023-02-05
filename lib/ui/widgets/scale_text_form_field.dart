import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/outlined_text_form_field_decoration.dart';

class ScaleTextFormField extends StatefulWidget {
  final Key? textFormKey;
  final bool autofocus;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChange;
  final TextInputType? keyboardType;
  final TextStyle? focusedStyle;
  final TextStyle? unfocusedStyle;
  final String? initialValue;
  final TextEditingController? controller;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;
  final Color? cursorColor;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final String? hintText;

  const ScaleTextFormField({
    super.key,
    this.textFormKey,
    this.autofocus = false,
    this.validator,
    this.decoration,
    this.onChanged,
    this.keyboardType,
    this.focusedStyle,
    this.unfocusedStyle,
    this.onFocusChange,
    this.controller,
    this.initialValue,
    this.maxLines,
    this.textAlignVertical,
    this.cursorColor,
    this.inputFormatters,
    this.suffixIcon,
    this.hintText,
  });

  @override
  State<ScaleTextFormField> createState() => _ScaleTextFormFieldState();
}

class _ScaleTextFormFieldState extends State<ScaleTextFormField> {
  final FocusNode focusNode = FocusNode();
  late TextStyle? focusedStyle;
  late TextStyle? unfocusedStyle;

  @override
  Widget build(BuildContext context) {
    focusedStyle = widget.focusedStyle ??
        ScaleTextStyles.text
            .apply(color: Theme.of(context).colorScheme.onPrimary);
    unfocusedStyle = widget.unfocusedStyle ??
        ScaleTextStyles.text
            .apply(color: Theme.of(context).colorScheme.tertiary);

    return Focus(
      onFocusChange: (focused) {
        widget.onFocusChange?.call(focused);
        setState(() {});
      },
      child: Stack(
        children: [
          TextFormField(
            key: widget.textFormKey,
            focusNode: focusNode,
            inputFormatters: widget.inputFormatters,
            initialValue: widget.initialValue,
            controller: widget.controller,
            autofocus: widget.autofocus,
            validator: widget.validator,
            decoration: OutlinedTextFormFieldDecoration(
              hintText: widget.hintText ?? '',
            ),
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            textAlignVertical: widget.textAlignVertical,
            cursorColor:
                widget.cursorColor ?? Theme.of(context).colorScheme.onPrimary,
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ).merge(
              focusNode.hasFocus ? focusedStyle : unfocusedStyle,
            ),
          ),
          if (widget.suffixIcon != null)
            Positioned(
              right: Dimensions.padding16,
              top: Dimensions.padding12,
              bottom: Dimensions.padding12,
              child: widget.suffixIcon!,
            )
        ],
      ),
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class IntTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class TimeTextFormatter extends TextInputFormatter {
  late RegExp pattern;
  TimeTextFormatter() {
    pattern = RegExp(r'^[0-9:]+$');
  }

  String pack(String value) {
    if (value.length != 4) return value;
    return '${value.substring(0, 2)}:${value.substring(2, 4)}';
  }

  String unpack(String value) {
    return value.replaceAll(':', '');
  }

  String complete(String value) {
    if (value.length >= 4) return value;
    final multiplier = 4 - value.length;
    return ('0' * multiplier) + value;
  }

  String limit(String value) {
    if (value.length <= 4) return value;
    return value.substring(value.length - 4, value.length);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!pattern.hasMatch(newValue.text)) return oldValue;

    TextSelection newSelection = newValue.selection;

    String toRender;
    String newText = newValue.text;

    toRender = '';
    if (newText.length < 5) {
      if (newText == '00:0') {
        toRender = '';
      } else {
        toRender = pack(complete(unpack(newText)));
      }
    } else if (newText.length == 6) {
      toRender = pack(limit(unpack(newText)));
    }

    newSelection = newValue.selection.copyWith(
      baseOffset: math.min(toRender.length, toRender.length),
      extentOffset: math.min(toRender.length, toRender.length),
    );

    return TextEditingValue(
      text: toRender,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
