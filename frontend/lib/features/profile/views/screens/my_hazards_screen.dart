import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/enums/my_hazards_tab_types.dart';
import 'package:hazard_app/features/profile/views/widgets/accepted_hazards_widgets/my_accepted_hazards_list.dart';
import 'package:hazard_app/features/profile/views/widgets/rejected_hazards_widgets/my_rejected_hazards_list.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The V3 section label colour from the design screenshots.
const _sectionLabelColor = Color(0xFFB84500);

class MyHazardsScreenArgs {
  const MyHazardsScreenArgs({
    this.initialTab = MyHazardsTab.accepted,
  });

  /// The initial tab to display when the screen is opened.
  final MyHazardsTab initialTab;
}

class MyHazardsScreen extends ConsumerStatefulWidget {
  const MyHazardsScreen({
    super.key,
    required this.args,
  });

  /// The arguments for the screen.
  final MyHazardsScreenArgs args;

  static const route = '/my-hazards';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyHazardsScreenState();
}

class _MyHazardsScreenState extends ConsumerState<MyHazardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.args.initialTab.index,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(title: const Text('My ALRTs')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.spMin, 14.spMin, 20.spMin, 0),
            child: _segmentedControlBuilder(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _tabBodyBuilder(
                  label: 'Live and reviewed',
                  description:
                      'ALRTs you posted that are visible to the community.',
                  child: MyAcceptedHazardsList(
                    shinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ),
                _tabBodyBuilder(
                  label: 'Needs changes',
                  description:
                      'These need an update before they can go live again.',
                  child: const MyRejectedHazardsList(
                    shinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// V3 pill segmented control driving the swipeable tab view.
  Widget _segmentedControlBuilder() {
    final selectedIndex = _tabController.index;
    final segments = [
      (LucideIcons.circleCheck, 'Accepted'),
      (LucideIcons.circleAlert, 'Needs changes'),
    ];

    return Container(
      padding: EdgeInsets.all(4.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          for (final (index, segment) in segments.indexed)
            Expanded(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40.spMin,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppColors.black.withValues(alpha: 0.9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        segment.$1,
                        size: 16.spMin,
                        color: selectedIndex == index
                            ? Colors.white
                            : AppColors.grey,
                      ),
                      SizedBox(width: 6.spMin),
                      Text(
                        segment.$2,
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                          color: selectedIndex == index
                              ? Colors.white
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabBodyBuilder({
    required final String label,
    required final String description,
    required final Widget child,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.spMin, 16.spMin, 20.spMin, 50.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5.spMin,
              color: _sectionLabelColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            description,
            style: TextStyle(fontSize: 12.5.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 12.spMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.spMin),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
