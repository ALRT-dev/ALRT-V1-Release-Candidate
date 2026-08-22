import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class FamilySosResolvedScreenArgs {
  const FamilySosResolvedScreenArgs({
    required this.event,
    this.circleName,
    this.recipientCount,
  });

  /// The stood-down SOS this record describes.
  final FamilySosEvent event;

  /// The circle it ran in, for the kicker.
  final String? circleName;

  /// How many people could see it while it ran.
  final int? recipientCount;
}

/// The after-event record for a stood-down SOS.
///
/// This screen is where the privacy promise becomes visible: it states what
/// was shared, for how long and to whom, and that the location data is gone
/// while the event log remains.
class FamilySosResolvedScreen extends ConsumerWidget {
  const FamilySosResolvedScreen({super.key, required this.args});

  final FamilySosResolvedScreenArgs args;

  static const route = '/family-sos-resolved';

  static const _ink = Color(0xFF3A3A42);
  static const _inkStrong = Color(0xFF1D1D21);
  static const _respondedBackground = Color(0xFFE4F7EE);
  static const _respondedInk = Color(0xFF0A8A58);
  static const _neutralPill = Color(0xFFF1EEF4);
  static const _noteBackground = Color(0xFFEEF0FF);
  static const _noteBorder = Color(0xFFD5D9FB);
  static const _noteInk = Color(0xFF3F3D9E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = args.event;

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      bottomNavigationBar: _backBarBuilder(context),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _headerBuilder(context, event),
          _whatWasSharedBuilder(event),
          _responsesBuilder(context, event),
          _noteBuilder(),
          20.hSizedBox,
        ],
      ),
    );
  }

  Widget _headerBuilder(final BuildContext context, final FamilySosEvent e) {
    final stoppedAt = e.resolvedAt;
    final who = e.member?.displayName ?? 'They';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [Color(0xFF5B54F0), FamilyColors.v31Indigo],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 22.spMin),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((args.circleName ?? '').isNotEmpty)
              Text(
                args.circleName!.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            3.hSizedBox,
            Text(
              'SOS resolved',
              style: TextStyle(
                fontSize: 26.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: Colors.white,
              ),
            ),
            5.hSizedBox,
            Text(
              stoppedAt == null
                  ? '$who stopped sharing'
                  : '$who stopped sharing at '
                        '${TimeOfDay.fromDateTime(stoppedAt).format(context)}',
              style: TextStyle(
                fontSize: 13.spMin,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _whatWasSharedBuilder(final FamilySosEvent e) {
    final started = e.createdAt;
    final ended = e.resolvedAt;
    final ranFor = started == null || ended == null
        ? null
        : ended.difference(started);
    final seenBy = args.recipientCount ?? e.responses.length;

    return _cardBuilder(
      label: 'What was shared',
      labelColor: const Color(0xFFB84500),
      topMargin: 13,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Live location ran for '),
            TextSpan(
              text: ranFor == null
                  ? 'the length of the SOS'
                  : _durationLabel(ranFor),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _inkStrong,
              ),
            ),
            TextSpan(
              text: seenBy > 0
                  ? ' and was visible to $seenBy '
                        '${seenBy == 1 ? 'family member' : 'family members'} '
                        'only.'
                  : ' and was visible to your circle only.',
            ),
            const TextSpan(
              text: ' It has now ended and no further location is available. '
                  'Snapshots from this session expire and are deleted '
                  'within 1 hour.',
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 13.5.spMin,
          height: 1.7,
          color: _ink,
        ),
      ),
    );
  }

  Widget _responsesBuilder(
    final BuildContext context,
    final FamilySosEvent e,
  ) {
    if (e.responses.isEmpty) {
      return _cardBuilder(
        label: 'Circle responses',
        labelColor: FamilyColors.v31Indigo,
        child: Text(
          'Nobody responded before it was stood down.',
          style: TextStyle(
            fontSize: 13.spMin,
            color: FamilyColors.v31Ink,
          ),
        ),
      );
    }

    return _cardBuilder(
      label: 'Circle responses',
      labelColor: FamilyColors.v31Indigo,
      child: Column(
        children: [
          for (final (index, response) in e.responses.indexed)
            Container(
              padding: EdgeInsets.symmetric(vertical: 7.spMin),
              decoration: index == 0
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: FamilyColors.v31Divider),
                      ),
                    ),
              child: _responseRowBuilder(context, response),
            ),
        ],
      ),
    );
  }

  Widget _responseRowBuilder(
    final BuildContext context,
    final FamilySosResponse response,
  ) {
    final name = response.member?.displayName ?? 'Family member';
    final isResponded = response.type == FamilySosResponseType.onMyWay ||
        response.type == FamilySosResponseType.called;
    final label = switch (response.type) {
      FamilySosResponseType.onMyWay => 'Responded',
      FamilySosResponseType.called => 'Responded',
      FamilySosResponseType.seen => 'Seen',
    };

    return Row(
      children: [
        Container(
          width: 38.spMin,
          height: 38.spMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: FamilyColors.memberColor(response.memberId),
            shape: BoxShape.circle,
          ),
          child: Text(
            _initialsOf(name),
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 11.spMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              Text(
                _responseDetail(context, response),
                style: TextStyle(
                  fontSize: 11.spMin,
                  color: FamilyColors.v31Ink,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 11.spMin,
            vertical: 5.spMin,
          ),
          decoration: BoxDecoration(
            color: isResponded ? _respondedBackground : _neutralPill,
            borderRadius: BorderRadius.circular(13.spMin),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w800,
              color: isResponded ? _respondedInk : FamilyColors.v31Ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _noteBuilder() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, 11.spMin, 16.spMin, 0),
      decoration: BoxDecoration(
        color: _noteBackground,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: _noteBorder),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14.spMin,
        vertical: 12.spMin,
      ),
      child: Text(
        'The event log survives, the location data does not. Provable '
        'process, no retained tracking.',
        style: TextStyle(
          fontSize: 11.5.spMin,
          height: 1.6,
          color: _noteInk,
        ),
      ),
    );
  }

  Widget _backBarBuilder(final BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 12.spMin),
        child: SizedBox(
          height: 48.spMin,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _inkStrong,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.spMin),
              ),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(
              'Back to Family',
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardBuilder({
    required final String label,
    required final Color labelColor,
    required final Widget child,
    final double topMargin = 11,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, topMargin.spMin, 16.spMin, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.spMin,
        vertical: 15.spMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: labelColor,
            ),
          ),
          SizedBox(height: 9.spMin),
          child,
        ],
      ),
    );
  }

  String _responseDetail(
    final BuildContext context,
    final FamilySosResponse response,
  ) {
    final at = response.createdAt;
    final time = at == null
        ? ''
        : ' ${TimeOfDay.fromDateTime(at).format(context)}';
    return switch (response.type) {
      FamilySosResponseType.onMyWay => 'On my way$time',
      FamilySosResponseType.called => 'Called$time',
      FamilySosResponseType.seen => 'Seen$time',
    };
  }

  static String _durationLabel(final Duration d) {
    if (d.inMinutes < 1) return 'under a minute';
    if (d.inMinutes < 60) return '${d.inMinutes} minutes';
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (minutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes min';
  }

  static String _initialsOf(final String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
