import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/sync_item.dart';

class SyncWidget extends StatelessWidget {
  const SyncWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => previous != current,
      bloc: syncBloc..add(const SyncEvent.init()),
      builder: (context, state) {
        return state.whenOrNull(none: () => true) == true
            ? const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              )
            : SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: Dimensions.padding16,
                    right: Dimensions.padding16,
                    top: Dimensions.padding16,
                  ),
                  child: SyncItem(
                    syncState: state,
                    onRefresh: () {
                      syncBloc.add(const SyncEvent.sync());
                    },
                  ),
                ),
              );
      },
    );
  }
}
