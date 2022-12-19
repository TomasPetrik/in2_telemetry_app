import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

class ScaleAppBar extends StatelessWidget {
  const ScaleAppBar({
    super.key,
    required this.title,
    this.showClose = false,
    this.onBackTap,
  });

  final String title;
  final bool showClose;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top,
      ),
      child: SizedBox(
        height: Constants.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: Dimensions.padding16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: onBackTap != null
                          ? IconButton(
                              onPressed: () {
                                onBackTap?.call();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: showClose
                          ? IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
