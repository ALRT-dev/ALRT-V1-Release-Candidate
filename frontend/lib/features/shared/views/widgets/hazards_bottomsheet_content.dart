import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/hazards_bottomsheet_list.dart';
import 'package:hazard_app/others/app_colors.dart';

class HazardsBottomsheetContent extends ConsumerStatefulWidget {
  const HazardsBottomsheetContent({
    super.key,
    required this.hazards,
  });

  /// The list of hazards to display.
  final List<Hazard> hazards;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardsBottomsheetContentState();
}

class _HazardsBottomsheetContentState
    extends ConsumerState<HazardsBottomsheetContent> {
  var _safeAreaTopPadding = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _safeAreaTopPadding = MediaQuery.of(context).padding.top;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                _safeAreaTopPadding.hSizedBox,
                10.hSizedBox,
                Expanded(
                  child: HazardsBottomsheetList(
                    hazards: widget.hazards,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0.0,
              left: 0.0,
              bottom: 80.spMin,
              child: _viewMapButtonBuilder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewMapButtonBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50.spMin,
          width: 140.spMin,
          child: Button.filled(
            onPressed: Navigator.of(context).pop,
            borderRadius: 50.0,
            color: const Color(0xFF3A3A3A),
            icon: Icon(
              Icons.map_rounded,
              size: 22.0,
              color: AppColors.white,
            ),
            value: 'View Map',
            valueStyle: TextStyle(
              color: AppColors.white,
            ),
            elevation: 3.0,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
