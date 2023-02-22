import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/sync_item.dart';

class SyncWidget extends StatelessWidget {
  const SyncWidget({
    super.key,
    required this.syncState,
  });

  final SyncState syncState;

  @override
  Widget build(BuildContext context) {
    return syncState.whenOrNull(none: () => true) == true
        ? const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          )
        : SliverPadding(
            padding: const EdgeInsets.all(
              Dimensions.padding16,
            ),
            sliver: SyncItem(
              syncState: syncState,
              onRefresh: () {
                getIt<SyncBloc>().add(const SyncEvent.syncAll());
              },
            ),
          );
  }
}
