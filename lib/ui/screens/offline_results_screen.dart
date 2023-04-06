import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/fixed_item_height_delegate.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/result_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class OfflineResultsScreen extends StatelessWidget with BottomSheetMixin {
  const OfflineResultsScreen({
    super.key,
  });

  void refreshResultsSync() {
    getIt<SyncBloc>().add(const SyncEvent.syncResults());
  }

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => previous != current,
      bloc: syncBloc..add(const SyncEvent.init()),
      builder: (context, syncState) {
        final session = getIt<Session>();

        final lastSyncAt = session.getLastSyncAt();
        final offlineResults = session.getOfflineResults() ?? [];

        final warningWidget = syncState.whenOrNull(
          inProgress: () => ProcessItem(
            processType: ProcessType.inProgress,
            label: context.locale.sync_widget_sync_in_progress,
          ),
          synced: () => ProcessItem(
            processType: ProcessType.done,
            label: context.locale.sync_widget_synced,
          ),
          syncUserDataFailed: (_, __) => WarningItem(
            title: context.locale.sync_widget_sync_results_failed_title,
            description: context.locale.sync_widget_sync_results_failed_desc,
            buttonLabel: context.locale.common_do_sync,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<SyncBloc>().add(
                const SyncEvent.syncAll(),
              );
            },
          ),
          userResultsFailed: (_, __) => WarningItem(
            title: context.locale.sync_widget_sync_results_failed_title,
            description: context.locale.sync_widget_sync_results_failed_desc,
            buttonLabel: context.locale.common_do_sync,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<SyncBloc>().add(
                const SyncEvent.syncAll(),
              );
            },
          ),
          someUsersResultsFailed: (_) => WarningItem(
            title: context.locale.sync_widget_sync_results_failed_title,
            description: context.locale.sync_widget_sync_results_failed_desc,
            buttonLabel: context.locale.common_do_sync,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<SyncBloc>().add(
                const SyncEvent.syncAll(),
              );
            },
          ),
          syncSomeUsersDataFailed: (_) => WarningItem(
            title: context.locale.sync_widget_sync_results_failed_title,
            description: context.locale.sync_widget_sync_results_failed_desc,
            buttonLabel: context.locale.common_do_sync,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<SyncBloc>().add(
                const SyncEvent.syncAll(),
              );
            },
          ),
        );

        return Material(
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: FixedHeightItemDelegate(
                      child: const SizedBox.shrink(),
                      fixedHeight: MediaQuery.of(context).viewPadding.top +
                          Dimensions.twoLinedBarHeight,
                    ),
                  ),
                  if (warningWidget != null) ...[
                    SliverPadding(
                      padding: Paddings.all16,
                      sliver: warningWidget,
                    ),
                    const SliverGap(Dimensions.padding8),
                  ],
                  const SliverGap(Dimensions.padding16),
                  SliverPadding(
                    padding: Paddings.horizontal16,
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        context.locale.sync_failed_screen_waiting_on_sync,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, int index) {
                        bool isSameDate = true;

                        final date = offlineResults[index].measurementDateTime;

                        if (index == 0) {
                          isSameDate = false;
                        } else {
                          final prevDate =
                              offlineResults[index - 1].measurementDateTime;
                          isSameDate = date.isSameDate(prevDate);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index == 0 || !(isSameDate)) ...[
                              Gaps.gap24,
                              Padding(
                                padding: Paddings.left16,
                                child: Text(
                                  date.toDateOrDay(context),
                                  style: ScaleTextStyles.label.apply(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              Gaps.gap8,
                            ],
                            ResultItem(
                              mResult: offlineResults[index],
                              onRemove: () async {
                                final confirmed =
                                    await showResultRemovalConfirmation(
                                  context: context,
                                  measurementType:
                                      offlineResults[index].measurementType!,
                                );

                                if (confirmed == true) {
                                  syncBloc.add(
                                    SyncEvent.removeOfflineResult(
                                      offlineResults[index],
                                    ),
                                  );
                                }
                              },
                            ),
                            if (index != (offlineResults.length - 1))
                              Container(
                                margin: Paddings.horizontal16,
                                height: 0.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          ],
                        );
                      },
                      childCount: offlineResults.length,
                    ),
                  ),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BluredScaleAppBar(
                  title: context.locale.sync_failed_screen_title,
                  subTitle: lastSyncAt == null
                      ? ''
                      : context.locale.sync_failed_screen_sub_title(
                          lastSyncAt.toDateOrDay(context),
                          lastSyncAt.toTimeOfDay().toString(),
                        ),
                  showClose: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
