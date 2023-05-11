import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class ScaleSearchBar extends StatefulWidget {
  const ScaleSearchBar({
    super.key,
    required this.searchHint,
    required this.searchController,
    this.autoFocus = false,
    required this.onBack,
  });

  final String searchHint;
  final TextEditingController searchController;
  final bool autoFocus;
  final VoidCallback onBack;

  @override
  State<ScaleSearchBar> createState() => _ScaleSearchBarState();
}

class _ScaleSearchBarState extends State<ScaleSearchBar> {
  final FocusNode _searchBoxNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoFocus) {
        FocusScope.of(context).requestFocus(_searchBoxNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints.tightFor(height: Dimensions.searchBarHeight),
      child: CupertinoTextField(
        focusNode: _searchBoxNode,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusSize.radius24),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        prefix: InkWell(
          onTap: () {
            widget.onBack.call();
          },
          child: Padding(
            padding: Paddings.horizontal16,
            child: SvgPicture.asset(
              'assets/icons/icon_back.svg',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        placeholder: widget.searchHint,
        selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
        placeholderStyle: ScaleTextStyles.text.apply(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        clearButtonMode: OverlayVisibilityMode.never,
        cursorColor: Theme.of(context).colorScheme.primary,
        style: ScaleTextStyles.text.apply(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        controller: widget.searchController,
      ),
    );
  }
}
