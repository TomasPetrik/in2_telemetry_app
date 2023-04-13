import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
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
              color: Theme.of(context).colorScheme.onPrimary,
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
