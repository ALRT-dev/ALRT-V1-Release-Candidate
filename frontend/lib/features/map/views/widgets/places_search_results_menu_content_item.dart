import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';

class PlacesSearchResultsMenuContentItem extends ConsumerStatefulWidget {
  const PlacesSearchResultsMenuContentItem({
    super.key,
    required this.place,
    this.onSelected,
  });

  final GooglePlace place;

  final void Function(GooglePlace)? onSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapSearchResultsListItemState();
}

class _MapSearchResultsListItemState
    extends ConsumerState<PlacesSearchResultsMenuContentItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: RoundButton(
        icon: Icon(
          Icons.location_on_outlined,
          size: 22.spMin,
        ),
      ),
      title: Text(
        widget.place.name,
        style: TextStyle(
          fontSize: 14.sp,
        ),
      ),
      subtitle: Text(
        widget.place.address,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      onTap: () {
        if (widget.onSelected != null) {
          widget.onSelected!(widget.place);
        }
      },
    );
  }
}
