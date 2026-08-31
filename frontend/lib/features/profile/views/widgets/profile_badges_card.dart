import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _earnedInk = Color(0xFF27AE60);
const _lockedInk = Color(0xFF9AA0A6);

/// The badge shelf on the safety profile.
///
/// Every badge here is earned by other people confirming your reports, not
/// by how much you post: that is the locked rule the scoring system sits
/// on. Locked badges are shown with their progress rather than hidden, so
/// what accuracy earns is visible before you have earned it.
class ProfileBadgesCard extends ConsumerWidget {
  const ProfileBadgesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(
      providerOfXpSummary.select((s) => s.value?.badges ?? const <SafetyBadge>[]),
    );
    if (badges.isEmpty) return const SizedBox.shrink();

    final earnedCount = badges.where((badge) => badge.earned).length;

    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(color: context.cardShadow, blurRadius: 2.0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.award, size: 20.spMin, color: _earnedInk),
              SizedBox(width: 10.spMin),
              Expanded(
                child: Text(
                  'Badges',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
              ),
              Text(
                '$earnedCount of ${badges.length}',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  fontWeight: FontWeight.w700,
                  color: context.onSurfaceMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.spMin),
          Text(
            'Earned when people nearby confirm what you reported.',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.4,
              color: context.onSurfaceMuted,
            ),
          ),
          SizedBox(height: 14.spMin),
          for (final (index, badge) in badges.indexed) ...[
            if (index > 0) SizedBox(height: 12.spMin),
            _badgeRowBuilder(context, badge),
          ],
        ],
      ),
    );
  }

  Widget _badgeRowBuilder(final BuildContext context, final SafetyBadge badge) {
    final ink = badge.earned ? _earnedInk : _lockedInk;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The medal itself carries the progress ring while it is locked, so
        // the shelf shows how close you are without a second control.
        SizedBox(
          width: 44.spMin,
          height: 44.spMin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!badge.earned)
                SizedBox(
                  width: 44.spMin,
                  height: 44.spMin,
                  child: CircularProgressIndicator(
                    value: badge.fraction,
                    strokeWidth: 3.spMin,
                    backgroundColor: _lockedInk.withValues(alpha: 0.16),
                    valueColor: AlwaysStoppedAnimation(
                      _earnedInk.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              Container(
                width: 34.spMin,
                height: 34.spMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: badge.earned ? 0.14 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge.earned ? LucideIcons.award : LucideIcons.lock,
                  size: 17.spMin,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.spMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 14.5.spMin,
                  fontWeight: FontWeight.w800,
                  color: badge.earned
                      ? context.onSurface
                      : context.onSurfaceMuted,
                ),
              ),
              SizedBox(height: 2.spMin),
              Text(
                badge.description,
                style: TextStyle(
                  fontSize: 12.spMin,
                  height: 1.35,
                  color: context.onSurfaceMuted,
                ),
              ),
              if (!badge.earned) ...[
                SizedBox(height: 4.spMin),
                Text(
                  '${badge.progress} of ${badge.threshold}',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: _earnedInk,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The banner shown when a badge is earned while the app is open.
///
/// A badge that arrives silently is not a reward. This is deliberately the
/// only celebration in the scoring system: corroborating someone else's
/// report still earns nothing and says so. Deliberately dark on any
/// background (not theme-driven) — a celebratory overlay, not a surface.
class BadgeEarnedBanner {
  const BadgeEarnedBanner._();

  static void show({
    required final BuildContext context,
    required final String name,
    required final String description,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10.spMin,
        left: 14.spMin,
        right: 14.spMin,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(14.spMin),
            decoration: BoxDecoration(
              color: const Color(0xFF15161A),
              borderRadius: BorderRadius.circular(18.spMin),
              border: Border.all(color: _earnedInk, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _earnedInk.withValues(alpha: 0.4),
                  blurRadius: 22.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40.spMin,
                  height: 40.spMin,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _earnedInk,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.award,
                    size: 20.spMin,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge earned: $name',
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.spMin),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.spMin,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 6), () {
      try {
        entry.remove();
      } catch (_) {
        // Navigation can tear the overlay down first; a celebration must
        // never be the thing that crashes the app on its way out.
      }
    });
  }
}
