import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/enums/my_hazards_tab_types.dart';
import 'package:hazard_app/features/profile/providers/my_hazards_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_hazards_provider_state.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_colors.dart';

class MyHazardsScreenArgs {
  const MyHazardsScreenArgs({
    this.initialTab = MyHazardsTab.accepted,
  });

  /// Which reports to list first. The prototype shows one list, so this
  /// only decides whether reports that need changes sit on top.
  final MyHazardsTab initialTab;
}

/// My ALRTs, as on the prototype "MyALRTs" board: white header with back
/// arrow, title and "Reports you posted", then one white card per report
/// with its title, "Live · confirmed by ×N" (or Ended / Needs changes) and
/// a chevron into the alert. Empty: "You have not posted anything yet."
class MyHazardsScreen extends ConsumerWidget {
  const MyHazardsScreen({
    super.key,
    required this.args,
  });

  /// The arguments for the screen.
  final MyHazardsScreenArgs args;

  static const route = '/my-hazards';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerOfMyHazards);

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(
            title: 'My ALRTs',
            subtitle: 'Reports you posted',
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.orange,
              onRefresh: () async {
                final notifier = ref.read(providerOfMyHazards.notifier);
                await Future.wait([
                  notifier.getMyAcceptedHazards(),
                  notifier.getMyRejectedHazards(),
                ]);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16.spMin,
                  14.spMin,
                  16.spMin,
                  32.spMin,
                ),
                children: _buildBody(context, state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(
    final BuildContext context,
    final MyHazardsProviderState state,
  ) {
    final acceptedLoading = state.getMyAcceptedHazardsState.maybeWhen(
      loading: () => true,
      initial: () => true,
      orElse: () => false,
    );
    final rejectedLoading = state.getMyRejectedHazardsState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final failed = state.getMyAcceptedHazardsState.maybeWhen(
      error: (_) => true,
      orElse: () => false,
    );

    final accepted = [
      for (final h in state.myAcceptedHazards) _ReportRow(hazard: h),
    ];
    final rejected = [
      for (final h in state.myRejectedHazards)
        _ReportRow(hazard: h, needsChanges: true),
    ];
    final rows = args.initialTab == MyHazardsTab.rejected
        ? [...rejected, ...accepted]
        : [...accepted, ...rejected];

    if (rows.isEmpty) {
      if (acceptedLoading || rejectedLoading) {
        return [
          Padding(
            padding: EdgeInsets.only(top: 32.spMin),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ];
      }
      return [
        ProfileCard(
          children: [
            ProfileMutedText(
              failed
                  ? 'Your reports could not be loaded. Pull down to try again.'
                  : 'You have not posted anything yet.',
            ),
          ],
        ),
      ];
    }

    return [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) SizedBox(height: 10.spMin),
        rows[i],
      ],
    ];
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.hazard, this.needsChanges = false});

  final Hazard hazard;
  final bool needsChanges;

  String get _title {
    final title = hazard.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return hazard.category?.name ?? 'Your report';
  }

  String get _status {
    if (needsChanges) return 'Needs changes';
    final word = hazard.isExpired ? 'Ended' : 'Live';
    return '$word · confirmed by ×${hazard.corroborationCount}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18.spMin),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.spMin),
        onTap: () => context.push(
          ViewHazardScreen.route,
          extra: ViewHazardScreenArgs(hazard: hazard),
        ),
        child: Container(
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.spMin),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 3.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    ProfileMutedText(_status, size: 12),
                  ],
                ),
              ),
              SizedBox(width: 10.spMin),
              Icon(
                Icons.chevron_right,
                size: 20.spMin,
                color: ProfilePageKit.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
