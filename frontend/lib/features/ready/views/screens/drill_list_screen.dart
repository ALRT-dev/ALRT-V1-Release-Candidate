import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/ready/views/screens/drill_create_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The family drill (board Drill): which group, the "Practise leave now
/// together" card with Start drill, then the drills already run, newest
/// first, from GET /ready/drills.
///
/// Start drill times the practice on this phone and records it as a drill
/// (POST /ready/drills) when everyone is out. The board's practice alert
/// to every member and the per-person "I'm out" times need backend that
/// does not exist yet, so the list shows each recorded drill instead.
class DrillListScreen extends ConsumerStatefulWidget {
  const DrillListScreen({super.key});

  static const route = '/ready/drills';

  @override
  ConsumerState<DrillListScreen> createState() => _DrillListScreenState();
}

class _DrillListScreenState extends ConsumerState<DrillListScreen> {
  static const _page = Color(0xFFF5F5F7);
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _line = Color(0xFFE3E6EA);
  static const _hairline = Color(0xFFECEEF1);
  static const _label = Color(0xFFB84500);
  static const _doneTint = Color(0xFFE6F4EA);
  static const _doneText = Color(0xFF146C2E);
  static const _insightTint = Color(0xFFEEF4FF);
  static const _insightText = Color(0xFF1E3A8A);

  /// The Family header gradient's first two stops (FamilyColors), as the
  /// board's Start drill button uses them.
  static const _startGradient = LinearGradient(
    colors: [Color(0xFF2E2A9E), Color(0xFF1E1780)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final readyState = ref.read(providerOfReady);
      if (!readyState.hasLoadedDrills) {
        ref.read(providerOfReady.notifier).loadDrills();
      }
    });
  }

  Future<void> _startDrill() async {
    final elapsed = await showModalBottomSheet<Duration>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (_) => const _DrillTimerSheet(),
    );
    if (elapsed == null || !mounted) return;
    final minutes = (elapsed.inSeconds / 60).ceil().clamp(1, 600);
    await ref
        .read(providerOfReady.notifier)
        .createDrill(
          title: 'Practise leave now',
          completedAt: DateTime.now(),
          durationMinutes: minutes,
        );
    if (!mounted) return;
    final error = ref.read(providerOfReady).error;
    if (error != null) {
      context.showErrorToast(message: error.message);
    } else {
      context.showSuccessToast(message: 'Drill recorded');
    }
  }

  @override
  Widget build(BuildContext context) {
    final readyState = ref.watch(providerOfReady);
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final drills = [...readyState.drills]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final memberCount = circle?.members.length ?? 0;

    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 24.spMin),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: Icon(LucideIcons.chevronLeft, color: _ink, size: 24.spMin),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            Text(
              circle == null
                  ? 'No family group yet'
                  : '${circle.name} · $memberCount '
                        '${memberCount == 1 ? 'member' : 'members'}',
              style: TextStyle(fontSize: 13.spMin, color: _muted),
            ),
            SizedBox(height: 4.spMin),
            Text(
              'Family drill',
              style: TextStyle(
                fontSize: 28.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: _ink,
              ),
            ),
            SizedBox(height: 20.spMin),
            _practiseCard(readyState.isSaving),
            SizedBox(height: 14.spMin),
            if (readyState.isLoadingDrills && drills.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.spMin),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (drills.isNotEmpty) ...[
              _sectionLabel(
                'Last drill · ${DateFormat('d MMM').format(drills.first.completedAt)}',
              ),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    for (var i = 0; i < drills.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                          color: _hairline,
                        ),
                      _drillRow(drills[i]),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 14.spMin),
            ],
            _insight(
              memberCount < 2
                  ? 'Add one family member first so there is someone to '
                        'practise with.'
                  : 'Include anyone without a phone, like a young child. '
                        'Agree who collects them before you start.',
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18.spMin),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ],
  );

  Widget _sectionLabel(final String text) => Padding(
    padding: EdgeInsets.only(bottom: 8.spMin),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: _label,
      ),
    ),
  );

  Widget _practiseCard(final bool isSaving) {
    final radius = BorderRadius.circular(14.spMin);
    return Container(
      padding: EdgeInsets.all(20.spMin),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANY TIME · 5 MINUTES',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: _label,
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            'Practise "leave now" together',
            style: TextStyle(
              fontSize: 20.spMin,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _ink,
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            'Everyone heads to the meeting point while this phone times '
            'it. No real emergency, no alarm.',
            style: TextStyle(fontSize: 14.spMin, height: 1.5, color: _muted),
          ),
          SizedBox(height: 14.spMin),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48.spMin,
                  decoration: BoxDecoration(
                    gradient: _startGradient,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1780).withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: radius,
                      onTap: isSaving ? null : _startDrill,
                      child: Center(
                        child: Text(
                          'Start drill',
                          style: TextStyle(
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.spMin),
              SizedBox(
                width: 112.spMin,
                height: 48.spMin,
                child: OutlinedButton(
                  onPressed: () => context.push(DrillCreateScreen.route),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: _line),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: radius),
                  ),
                  child: Text(
                    'Log one',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drillRow(final EmergencyDrill drill) {
    final minutes = drill.durationMinutes;
    final sub = [
      minutes == null ? 'Recorded' : 'Everyone out in $minutes min',
      DateFormat('d MMM').format(drill.completedAt),
    ].join(' · ');
    return Dismissible(
      key: ValueKey(drill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 18.spMin),
        color: AppColors.red,
        child: Icon(LucideIcons.trash2, color: Colors.white, size: 22.spMin),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete this drill?'),
          content: const Text('The drill record is removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Delete', style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          ref.read(providerOfReady.notifier).deleteDrill(drill.id),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
        child: Row(
          children: [
            Container(
              width: 36.spMin,
              height: 36.spMin,
              decoration: const BoxDecoration(
                color: _ink,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.footprints,
                size: 18.spMin,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drill.title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  Text(sub, style: TextStyle(fontSize: 13.spMin, color: _muted)),
                ],
              ),
            ),
            Container(
              height: 24.spMin,
              padding: EdgeInsets.symmetric(horizontal: 10.spMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _doneTint,
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  color: _doneText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insight(final String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      decoration: BoxDecoration(
        color: _insightTint,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.lightbulb, size: 18.spMin, color: _insightText),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Tip: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: text),
                ],
              ),
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.5,
                color: _insightText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The running drill: a stopwatch, "Everyone is out" to record it and
/// "Cancel drill" to drop it. Pops the elapsed time, or null.
class _DrillTimerSheet extends StatefulWidget {
  const _DrillTimerSheet();

  @override
  State<_DrillTimerSheet> createState() => _DrillTimerSheetState();
}

class _DrillTimerSheetState extends State<_DrillTimerSheet> {
  final _watch = Stopwatch();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _watch.start();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _watch.stop();
    super.dispose();
  }

  String get _clock {
    final s = _watch.elapsed.inSeconds;
    final m = s ~/ 60;
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.spMin, 20.spMin, 16.spMin, 12.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Drill running',
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              'Everyone heads to the meeting point. Tap when everyone is out.',
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.45,
                color: const Color(0xFF5C5C66),
              ),
            ),
            SizedBox(height: 20.spMin),
            Center(
              child: Text(
                _clock,
                style: TextStyle(
                  fontSize: 48.spMin,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(height: 20.spMin),
            SizedBox(
              height: 54.spMin,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1780),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_watch.elapsed),
                child: Text(
                  'Everyone is out',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.spMin),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5C5C66),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel drill'),
            ),
          ],
        ),
      ),
    );
  }
}
