import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    required this.searchHint,
    required this.searchController,
    this.autoFocus = false,
    this.onBack,
  });

  final String searchHint;
  final TextEditingController? searchController;
  final bool autoFocus;
  final VoidCallback? onBack;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
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
          const BoxConstraints.tightFor(height: Constants.searchBarHeight),
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
            widget.onBack?.call();
          },
          child: Padding(
            padding: Paddings.horizontal16,
            child: Icon(
              Icons.arrow_back,
              size: 20.0,
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
