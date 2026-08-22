import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/providers/my_hazards_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_hazards_provider_state.dart';
import 'package:hazard_app/features/profile/views/widgets/rejected_hazards_widgets/my_rejected_hazards_list_item.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class MyRejectedHazardsList extends ConsumerStatefulWidget {
  const MyRejectedHazardsList({
    super.key,
    this.limit,
    this.shinkWrap = false,
    this.physics,
  });

  /// The maximum number of items to display. If null, all items are displayed.
  final int? limit;

  /// Whether the list should shrink to fit its content.
  final bool shinkWrap;

  /// The scroll physics for the list.
  final ScrollPhysics? physics;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyRejectedHazardsListState();
}

class _MyRejectedHazardsListState extends ConsumerState<MyRejectedHazardsList> {
  @override
  Widget build(BuildContext context) {
    final getMyRejectedHazardsState = ref.watch(
      providerOfMyHazards.select(
        (value) => value.getMyRejectedHazardsState,
      ),
    );

    return getMyRejectedHazardsState.maybeWhen(
      loading: _loadingBuilder,
      error: _errorBuilder,
      success: (_) => _dataBuilder(),
      orElse: () => const SizedBox(),
    );
  }

  Widget _loadingBuilder() {
    return Spinner();
  }

  Widget _errorBuilder(final AppError error) {
    return Center(
      child: Text(
        'We encountered an error loading recent reports',
      ),
    );
  }

  Widget _dataBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final recentReports = ref.watch(
          providerOfMyHazards.select(
            (value) => value.myRejectedHazards,
          ),
        );

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView.separated(
            itemCount: widget.limit == null
                ? recentReports.length
                : min(recentReports.length, widget.limit!),
            shrinkWrap: widget.shinkWrap,
            physics: widget.physics,
            itemBuilder: (context, index) {
              final report = recentReports[index];
              return MyRejectedHazardsListItem(
                report: report,
              );
            },
            separatorBuilder: (context, index) => 10.hSizedBox,
          ),
        );
      },
    );
  }
}
