import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_actions.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every group you belong to, on one dark page, each wearing its own beacon.
///
/// The colour is the point: a group is recognised before its name is read,
/// which is why the cards are full-bleed gradients rather than list rows.
/// The seat card at the bottom is the honest arithmetic of what the
/// subscription is paying for, so the cost of one more group is visible
/// before it is spent rather than at the paywall.
class FamilySwitchGroupScreen extends ConsumerWidget {
  const FamilySwitchGroupScreen({super.key});

  static const route = '/family-switch-group';

  /// ALRT+ carries 8 seats across up to 4 owned circles (locked spec).
  static const _maxSeats = 8;

  static const _page = Color(0xFF0E0E12);
  static const _seatLabel = Color(0xFFE05A00);
  static const _seatPillBackground = Color(0xFFFFF3E8);
  static const _seatPillInk = Color(0xFFB84500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    final selectedId = ref.watch(providerOfSelectedCircleId);
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));

    // With no explicit selection the family tab shows the first circle, so
    // the switcher has to highlight the same one or CURRENT lies.
    final currentId = selectedId ?? circles.firstOrNull?.circleId;

    return Scaffold(
      backgroundColor: _page,
      body: ListView(
        padding: EdgeInsets.only(bottom: 104.spMin),
        children: [
          _headerBuilder(context),
          ...circles.map(
            (summary) => Padding(
              padding: EdgeInsets.fromLTRB(16.spMin, 0, 16.spMin, 11.spMin),
              child: _groupCardBuilder(
                context: context,
                ref: ref,
                summary: summary,
                isCurrent: summary.circleId == currentId,
                // Members are only loaded for the circle in scope, so the
                // dots ride on the current card and nowhere else.
                loaded: summary.circleId == currentId ? circle : null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.spMin),
            child: _seatCardBuilder(circles),
          ),
          _actionsBuilder(context, ref),
        ],
      ),
    );
  }

  /// Being in a group never closes the door on the next one: joining with a
  /// code is free and unlimited, and a host can split their seats across up
  /// to 4 groups they own. Both paths live here, on the switcher, where the
  /// question "can I be in another group?" actually gets asked.
  Widget _actionsBuilder(final BuildContext context, final WidgetRef ref) {
    ref.listen(providerOfFamily.select((s) => s.joinCircleState), (
      prev,
      next,
    ) {
      if (prev != next && next.isError && next.error != null) {
        context.showErrorToast(message: next.error!.message);
      }
    });
    ref.listen(providerOfFamily.select((s) => s.createCircleState), (
      prev,
      next,
    ) {
      if (prev != next && next.isError && next.error != null) {
        context.showErrorToast(message: next.error!.message);
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48.spMin,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.spMin),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
              ),
              onPressed: () => showJoinGroupSheet(context, ref),
              child: Text(
                'Join another group with a code',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: 9.spMin),
          SizedBox(
            height: 48.spMin,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFC939DD),
                    Color(0xFFA22CC6),
                    Color(0xFF7E1FA8),
                    Color(0xFF5C1585),
                  ],
                  stops: [0.0, 0.4, 0.74, 1.0],
                ),
                borderRadius: BorderRadius.circular(15.spMin),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.spMin),
                  ),
                ),
                onPressed: () => showCreateGroupSheet(context, ref),
                child: Text(
                  'Create another group',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.spMin),
            child: Text(
              'Joining with a code is always free, in as many groups as '
              'you like. Your ALRT+ seats can host up to 4 groups.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.spMin,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBuilder(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 52.spMin, 16.spMin, 14.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 30.spMin,
                  height: 30.spMin,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.x, size: 14.spMin, color: Colors.white),
                ),
              ),
              SizedBox(width: 11.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR GROUPS',
                      style: TextStyle(
                        fontSize: 11.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    Text(
                      'Switch between groups',
                      style: TextStyle(
                        fontSize: 23.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5.spMin),
          Text(
            'Each with its own name and beacon colour',
            style: TextStyle(
              fontSize: 12.5.spMin,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  /// One group, wearing its beacon as a gradient. Tapping rescopes the whole
  /// family tab and returns, so the switch is felt on the hub, not here.
  Widget _groupCardBuilder({
    required final BuildContext context,
    required final WidgetRef ref,
    required final FamilyCircleSummary summary,
    required final bool isCurrent,
    required final FamilyCircle? loaded,
  }) {
    final beacon = _beaconOf(summary);
    final lift = _lighten(beacon, 0.16);

    return GestureDetector(
      onTap: () async {
        if (!isCurrent) {
          await ref.read(providerOfFamily.notifier).selectCircle(
                summary.circleId,
              );
        }
        if (!context.mounted) return;
        Navigator.of(context).maybePop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.spMin,
          vertical: 15.spMin,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.8, -1),
            end: const Alignment(0.8, 1),
            colors: [lift, beacon],
          ),
          borderRadius: BorderRadius.circular(18.spMin),
          boxShadow: [
            BoxShadow(
              color: beacon.withValues(alpha: 0.36),
              blurRadius: 26.spMin,
              offset: Offset(0, 10.spMin),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // The group's own picture, so a switcher of same-coloured
                // cards is still told apart at a glance.
                FamilyGroupAvatar(
                  name: summary.name,
                  photoUrl: summary.photoUrl,
                  themeColorHex: summary.themeColor,
                  size: 38.spMin,
                  borderColor: Colors.white.withValues(alpha: 0.55),
                  borderWidth: 1.6,
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Text(
                    summary.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17.spMin,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.spMin),
                _pillBuilder(
                  label: isCurrent ? 'CURRENT' : _roleLabelOf(summary),
                  isCurrent: isCurrent,
                ),
              ],
            ),
            SizedBox(height: 3.spMin),
            Text(
              _subtitleOf(summary),
              style: TextStyle(
                fontSize: 11.5.spMin,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            if (loaded != null && loaded.members.isNotEmpty) ...[
              SizedBox(height: 11.spMin),
              _memberDotsBuilder(loaded, beacon),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pillBuilder({
    required final String label,
    required final bool isCurrent,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 4.spMin),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.spMin),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Overlapping initials with a count of who has checked in. The ring is the
  /// beacon so the dots read as belonging to this card, not floating on it.
  Widget _memberDotsBuilder(final FamilyCircle circle, final Color beacon) {
    final members = circle.members.take(5).toList();
    final safeCount = circle.members.where((m) => m.isCheckedInRecently).length;

    return Row(
      children: [
        SizedBox(
          height: 24.spMin,
          width: (24 + (members.length - 1) * 16).spMin,
          child: Stack(
            children: [
              for (var index = 0; index < members.length; index++)
                Positioned(
                  left: (index * 16).spMin,
                  child: Container(
                    width: 24.spMin,
                    height: 24.spMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: FamilyColors.memberColor(members[index].id),
                      shape: BoxShape.circle,
                      border: Border.all(color: beacon, width: 2.spMin),
                    ),
                    child: Text(
                      members[index].initials,
                      style: TextStyle(
                        fontSize: 8.spMin,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.spMin),
        Text(
          '$safeCount of ${circle.members.length} safe',
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// The seat arithmetic, spelled out. Only circles you own spend your seats,
  /// so joined groups are deliberately absent from the breakdown.
  Widget _seatCardBuilder(final List<FamilyCircleSummary> circles) {
    final owned = circles.where((c) => c.isOwned).toList();
    final used = owned.fold<int>(0, (sum, c) => sum + c.seatCount);
    final spare = (_maxSeats - used).clamp(0, _maxSeats);

    return Container(
      margin: EdgeInsets.only(top: 3.spMin),
      padding: EdgeInsets.symmetric(horizontal: 15.spMin, vertical: 14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.spMin),
                  child: Text(
                    'SEATS ACROSS YOUR GROUPS',
                    style: TextStyle(
                      fontSize: 10.spMin,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: _seatLabel,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.spMin),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.spMin,
                  vertical: 6.spMin,
                ),
                decoration: BoxDecoration(
                  color: _seatPillBackground,
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Text(
                  '$used of $_maxSeats\nused',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: _seatPillInk,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.spMin),
          Text(
            owned.isEmpty
                ? "You don't host a group yet, so none of your seats are "
                      'in use.'
                : '${owned.map((c) => '${c.name} ${c.seatCount}').join(' · ')}'
                      '\n$spare spare',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.5,
              color: FamilyColors.v31Ink,
            ),
          ),
        ],
      ),
    );
  }

  /// Everything that isn't the current group still needs a word: who hosts
  /// it decides whether it costs you a seat.
  String _roleLabelOf(final FamilyCircleSummary summary) =>
      summary.isOwned ? 'YOU HOST' : 'JOINED';

  String _subtitleOf(final FamilyCircleSummary summary) {
    final seats = summary.isOwned
        ? '${summary.seatCount} ${summary.seatCount == 1 ? 'seat' : 'seats'}'
        : 'no seats of yours';
    final people = '${summary.memberCount} '
        '${summary.memberCount == 1 ? 'person' : 'people'}';
    final host = summary.isOwned ? 'you host' : 'hosted by someone else';
    return '$seats · $people · $host';
  }

  /// The group's chosen beacon, falling back to the family indigo so a group
  /// that has never been themed still looks deliberate.
  Color _beaconOf(final FamilyCircleSummary summary) {
    final hex = summary.themeColor?.trim();
    if (hex == null || hex.isEmpty) return FamilyColors.indigo;

    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return FamilyColors.indigo;
    return Color(cleaned.length <= 6 ? value | 0xFF000000 : value);
  }

  /// The top-left stop of the card gradient: the same beacon, lifted, so
  /// every card shares one light source.
  Color _lighten(final Color color, final double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
