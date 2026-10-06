import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_hub_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_onboarding_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The Family tab body: loads the circle, starts/stops the live-location
/// pinger based on membership, and shows onboarding or the hub.
class FamilyTabView extends ConsumerStatefulWidget {
  const FamilyTabView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamilyTabViewState();
}

class _FamilyTabViewState extends ConsumerState<FamilyTabView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(providerOfFamily.notifier).load(),
    );
  }

  // The resume refresh (socket reconnect + silent circle reload) lives on
  // HomeScreen so it runs whichever tab is showing, not only this one.

  @override
  Widget build(BuildContext context) {
    final hasLoadedOnce = ref.watch(
      providerOfFamily.select((s) => s.hasLoadedOnce),
    );
    final loadState = ref.watch(providerOfFamily.select((s) => s.loadState));
    // Belonging to a group is decided by MEMBERSHIP, not by whether the
    // selected circle's detail happens to be loaded. `circle` is only the
    // circle currently in scope: when it is briefly null (a switch, a slow
    // detail fetch, a failed refresh) a member used to be shown the
    // "Create a group" pitch, complete with a paywall button, as though
    // they had no family at all. If you are in a group, you always see it.
    final isInAGroup = ref.watch(
      providerOfFamily.select(
        (s) => s.circle != null || s.circles.isNotEmpty,
      ),
    );
    final hasScopedCircle = ref.watch(
      providerOfFamily.select((s) => s.circle != null),
    );

    if (!hasLoadedOnce) {
      if (loadState.isError) {
        return _errorBuilder();
      }
      return const Center(
        child: CircularProgressIndicator(color: FamilyColors.indigo),
      );
    }

    // A failed load with nothing to show is a retry, never the
    // create-a-group pitch: only a SUCCESSFUL load may conclude the user
    // has no group.
    if (!isInAGroup && loadState.isError) return _errorBuilder();
    if (!isInAGroup) return const FamilyOnboardingScreen();
    // In a group, detail still arriving: wait, never fall back to the pitch.
    if (!hasScopedCircle) {
      return const Center(
        child: CircularProgressIndicator(color: FamilyColors.indigo),
      );
    }
    return const FamilyHubScreen();
  }

  Widget _errorBuilder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load your family circle',
            style: TextStyle(fontSize: 15.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 10.spMin),
          OutlinedButton(
            onPressed: () => ref.read(providerOfFamily.notifier).load(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}
