import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';

class HazardsBottomsheetList extends ConsumerStatefulWidget {
  const HazardsBottomsheetList({
    super.key,
    required this.hazards,
  });

  /// The list of hazards to display.
  final List<Hazard> hazards;

  @override
  ConsumerState<HazardsBottomsheetList> createState() =>
      _HazardsBottomsheetListState();
}

class _HazardsBottomsheetListState
    extends ConsumerState<HazardsBottomsheetList> {
  @override
  Widget build(BuildContext context) {
    if (widget.hazards.isEmpty) {
      return _emptyBuilder();
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        itemCount: widget.hazards.length,
        itemBuilder: (context, index) {
          final hazard = widget.hazards[index];
          return CommonHazardsListItem(
            key: ValueKey(hazard.id),
            hazard: hazard,
          ).pB(index == widget.hazards.length - 1 ? 120.0 : 0.0);
        },
        separatorBuilder: (context, index) => 15.hSizedBox,
      ),
    );
  }

  Widget _emptyBuilder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nothing to show!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'There are no alerts to display.',
            textAlign: TextAlign.center,
          ),
        ],
      ).pad(40.0),
    );
  }
}
