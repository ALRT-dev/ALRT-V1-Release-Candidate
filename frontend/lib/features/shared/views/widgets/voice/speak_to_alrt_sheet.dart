import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/family/repositories/family_repository.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/services/alert_speech_service.dart';
import 'package:hazard_app/features/shared/services/voice_command.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/saved_location_gate.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Speak to ALRT (ruling 16 Oct 2026, one mic): shows what was heard and
/// what ALRT took it to mean, asks first for anything that saves, sends or
/// checks in, does it through the existing endpoints, and reads the reply
/// aloud. Search, questions and hazard reports are handed back to the map
/// search bar, which already owns those flows.
Future<void> showSpeakToAlrtSheet({
  required final BuildContext context,
  required final VoiceCommand command,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (_) => SpeakToAlrtSheet(command: command),
  );
}

enum _Phase { confirm, working, done }

class SpeakToAlrtSheet extends ConsumerStatefulWidget {
  const SpeakToAlrtSheet({super.key, required this.command});

  final VoiceCommand command;

  @override
  ConsumerState<SpeakToAlrtSheet> createState() => _SpeakToAlrtSheetState();
}

class _NextStep {
  const _NextStep(this.label, this.onTap);
  final String label;
  final Future<void> Function(BuildContext) onTap;
}

class _SpeakToAlrtSheetState extends ConsumerState<SpeakToAlrtSheet> {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _orange = Color(0xFFE8622A);
  static const _replyTint = Color(0xFFFFF4EE);

  late _Phase _phase;
  String _question = '';
  String _reply = '';
  _NextStep? _next;

  // Resolved before asking, so the confirmation names exactly what happens.
  Hazard? _alert;
  String? _circleId;
  String? _circleName;
  int? _circleSize;

  @override
  void initState() {
    super.initState();
    final c = widget.command;
    if (c.kind == VoiceCommandKind.sendAlert) _resolveSend();
    if (c.kind == VoiceCommandKind.checkIn) _resolveCircle('');
    if (c.needsConfirmation && _reply.isEmpty) {
      _phase = _Phase.confirm;
      _question = _confirmQuestion();
      WidgetsBinding.instance.addPostFrameCallback((_) => _say(_question));
    } else if (_reply.isNotEmpty) {
      _phase = _Phase.done;
      WidgetsBinding.instance.addPostFrameCallback((_) => _say(_reply));
    } else {
      _phase = _Phase.working;
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  @override
  void dispose() {
    ref.read(providerOfAlertSpeech).stop();
    super.dispose();
  }

  // ---------------------------------------------------------------- lookups

  List<Hazard> get _liveAlerts {
    try {
      return ref
          .read(providerOfMap)
          .hazards
          .where((h) => !h.isExpired)
          .toList();
    } catch (_) {
      return const <Hazard>[];
    }
  }

  static int _rank(final Hazard h) =>
      (h.severityBand ?? HazardSeverityBand.info).index;

  /// The alert the words name, else the most serious official alert nearby.
  Hazard? _pickAlert(final String? words) {
    final live = _liveAlerts;
    if (live.isEmpty) return null;
    final terms = (words ?? '')
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 3)
        .where((t) => !const {'alert', 'warning', 'near', 'one', 'out'}.contains(t))
        .toList();
    String text(final Hazard h) =>
        '${h.title ?? ''} ${h.locationName ?? ''} ${h.category?.name ?? ''}'
            .toLowerCase();
    if (terms.isNotEmpty) {
      final all = live.where((h) => terms.every((t) => text(h).contains(t)));
      if (all.isNotEmpty) return all.first;
      final any = live.where((h) => terms.any((t) => text(h).contains(t)));
      if (any.isNotEmpty) return any.first;
    }
    final official = live.where((h) => !h.isUserReported).toList()
      ..sort((a, b) => _rank(b).compareTo(_rank(a)));
    return official.isNotEmpty ? official.first : live.first;
  }

  void _resolveCircle(final String words) {
    final family = ref.read(providerOfFamily);
    final circles = family.circles;
    if (circles.isEmpty) {
      _reply = "You're not in a group yet. Create one in Family first.";
      return;
    }
    final w = words.toLowerCase();
    final selected = ref.read(providerOfSelectedCircleId) ?? family.circle?.id;
    final named = w.isEmpty
        ? null
        : circles.where((c) => c.name
            .toLowerCase()
            .split(RegExp(r'\s+'))
            .any((t) => t.length >= 3 && w.contains(t)));
    final circle = (named != null && named.isNotEmpty)
        ? named.first
        : circles.firstWhere(
            (c) => c.circleId == selected,
            orElse: () => circles.first,
          );
    _circleId = circle.circleId;
    _circleName = circle.name;
    _circleSize = circle.memberCount;
  }

  void _resolveSend() {
    _alert = _pickAlert(widget.command.alertWords);
    if (_alert == null) {
      _reply = 'There is no alert near you to send right now.';
      return;
    }
    _resolveCircle(widget.command.groupWords ?? '');
  }

  String _confirmQuestion() {
    final c = widget.command;
    switch (c.kind) {
      case VoiceCommandKind.savePlace:
        return 'Save ${c.place} as a place, and get alerts there?';
      case VoiceCommandKind.sendAlert:
        final people = (_circleSize ?? 0) > 0 ? ' ($_circleSize people)' : '';
        return 'Send "${_alert?.title ?? 'this alert'}" to $_circleName$people?';
      case VoiceCommandKind.checkIn:
        return 'Check in with $_circleName now?';
      default:
        return '';
    }
  }

  // ------------------------------------------------------------------ doing

  Future<void> _say(final String text) =>
      ref.read(providerOfAlertSpeech).speak(text);

  Future<void> _run() async {
    setState(() => _phase = _Phase.working);
    String reply;
    _NextStep? next;
    try {
      switch (widget.command.kind) {
        case VoiceCommandKind.savePlace:
          (reply, next) = await _savePlace();
        case VoiceCommandKind.sendAlert:
          reply = await _sendAlert();
        case VoiceCommandKind.checkIn:
          reply = await _checkIn();
        case VoiceCommandKind.readAlert:
          (reply, next) = _readAlert();
        case VoiceCommandKind.nearMe:
          reply = _nearMe();
        case VoiceCommandKind.sosRefused:
          reply = "SOS can't be sent by voice. Open Family and hold the SOS "
              'button for 3 seconds.';
        default:
          reply = '';
      }
    } catch (_) {
      reply = 'Something went wrong. Try again.';
    }
    if (!mounted) return;
    setState(() {
      _phase = _Phase.done;
      _reply = reply;
      _next = next;
    });
    await _say(reply);
  }

  Future<(String, _NextStep?)> _savePlace() async {
    final name = widget.command.place ?? '';
    final mapService = ref.read(providerOfMapService);
    final found = await mapService.getPlaces(
      searchString: name,
      currentUserLocation: ref.read(providerOfLocation).location,
    );
    final places = found.when((p) => p, (_) => null);
    if (places == null) {
      return ("Couldn't search for $name. Check your connection.", null);
    }
    if (places.isEmpty) return ("Couldn't find $name.", null);
    final place = places.first;

    final saved = ref.read(providerOfMyLocationSubscriptions);
    final savedCount =
        saved.locationSubscriptions.where((s) => !s.isOwnLocation).length;
    bool isPlus;
    try {
      isPlus = await ref.read(providerOfAlrtPlus.future);
    } catch (_) {
      return ('Could not check your plan. Try again.', null);
    }
    if (savedLocationGate(savedCount: savedCount, isPlus: isPlus) ==
        SavedLocationGate.needsPlus) {
      return (
        'ALRT Free includes $kFreeSavedLocationsLimit saved place as well as '
            'where you are. ALRT + gives you unlimited places.',
        _NextStep('See ALRT +', (ctx) async {
          await ctx.push<bool>(
            AlrtPlusPaywallScreen.route,
            extra: const AlrtPlusPaywallArgs(
              reason: AlrtPlusPaywallReason.savedLocation,
            ),
          );
        }),
      );
    }

    await ref
        .read(providerOfMyLocationSubscriptions.notifier)
        .subscribeToLocation(location: place.toAlrtLocation);
    final wrappers = ref
        .read(providerOfMyLocationSubscriptions)
        .subscribeToLocationStateWrappers;
    final outcome = wrappers.isEmpty
        ? 'failed'
        : wrappers.last.subscribeToLocationState.maybeWhen(
            success: () => 'saved',
            // 402 = the personal saved-place limit, refused by the server.
            error: (error) => error.code == '402' ? 'limit' : 'failed',
            orElse: () => 'failed',
          );
    if (outcome == 'limit') {
      return (
        'ALRT Free includes $kFreeSavedLocationsLimit saved place as well as '
            'where you are. ALRT + gives you unlimited places.',
        null,
      );
    }
    if (outcome != 'saved') {
      return ("Couldn't save ${place.name}. Try again.", null);
    }
    return ("Saved. You'll get alerts for ${place.name}.", null);
  }

  Future<String> _sendAlert() async {
    final hazardId = _alert?.id;
    final circleId = _circleId;
    if (hazardId == null || circleId == null) return 'Nothing was sent.';
    final result = await ref
        .read(providerOfFamilyRepository)
        .shareHazardWithCircle(circleId: circleId, hazardId: hazardId);
    return result.when(
      (_) => 'Sent "${_alert?.title ?? 'the alert'}" to $_circleName.',
      (error) => error.message.isEmpty ? 'That did not send.' : error.message,
    );
  }

  Future<String> _checkIn() async {
    await ref.read(providerOfFamily.notifier).checkIn(shareLocation: false);
    final state = ref.read(providerOfFamily).checkInState;
    return state.isSuccess
        ? 'Checked in. $_circleName has been told.'
        : 'Check in did not go through. Open Family to try again.';
  }

  (String, _NextStep?) _readAlert() {
    final h = _pickAlert(widget.command.alertWords);
    if (h == null) return ('There are no alerts near you right now.', null);
    final parts = <String>[
      if (h.isUserReported)
        'Community report, unverified.'
      else if (h.isAwsCompliant == true)
        '${h.severityTitle}.',
      '${h.title ?? 'Alert'}.',
      if ((h.source?.name ?? '').isNotEmpty) 'From ${h.source!.name}.',
      if ((h.aiSummary ?? '').isNotEmpty)
        h.aiSummary!
      else if ((h.description ?? '').isNotEmpty)
        h.description!,
    ];
    return (
      parts.join(' '),
      _NextStep('Open the alert', (ctx) async {
        await ctx.push(
          ViewHazardScreen.route,
          extra: ViewHazardScreenArgs(hazard: h),
        );
      }),
    );
  }

  String _nearMe() {
    final live = _liveAlerts;
    final warnings = live
        .where((h) => !h.isUserReported)
        .where((h) =>
            h.severityBand == HazardSeverityBand.action ||
            h.severityBand == HazardSeverityBand.critical)
        .toList()
      ..sort((a, b) => _rank(b).compareTo(_rank(a)));
    if (warnings.isEmpty) {
      final n = live.length;
      return 'No warnings near you right now. '
          '$n alert${n == 1 ? '' : 's'} on the map here.';
    }
    final top = warnings.first;
    final level = top.isAwsCompliant == true ? ', ${top.severityTitle}' : '';
    final n = warnings.length;
    return '$n warning${n == 1 ? '' : 's'} near you. The most serious is '
        '${top.title ?? 'an alert'}$level.';
  }

  // ------------------------------------------------------------------- view

  @override
  Widget build(BuildContext context) {
    final c = widget.command;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 16.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              'Speak to ALRT',
              style: TextStyle(
                fontSize: 20.spMin,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 12.spMin),
            Text(
              '"${c.heard}"',
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w700,
                color: _ink,
                height: 1.3,
              ),
            ),
            SizedBox(height: 4.spMin),
            Text(
              c.label,
              style: TextStyle(fontSize: 13.spMin, color: _muted),
            ),
            SizedBox(height: 16.spMin),
            ..._body(context),
            SizedBox(height: 12.spMin),
            Text(
              'Anything that saves, sends or checks in asks you first. SOS is '
              'never done by voice.',
              style: TextStyle(fontSize: 12.spMin, color: _muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(final BuildContext context) {
    switch (_phase) {
      case _Phase.confirm:
        return [
          Text(
            _question,
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.spMin),
          _primary(_yesLabel(), _run),
          SizedBox(height: 8.spMin),
          _secondary('No', () async {
            setState(() {
              _phase = _Phase.done;
              _reply = 'OK, nothing was done.';
            });
            await _say(_reply);
          }),
        ];
      case _Phase.working:
        return [
          Center(
            child: SizedBox(
              width: 24.spMin,
              height: 24.spMin,
              child: const CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ];
      case _Phase.done:
        return [
          Container(
            padding: EdgeInsets.all(12.spMin),
            decoration: BoxDecoration(
              color: _replyTint,
              borderRadius: BorderRadius.circular(14.spMin),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.volume2, size: 18.spMin, color: _orange),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Text(
                    _reply,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      color: _ink,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_next != null) ...[
            SizedBox(height: 12.spMin),
            _primary(_next!.label, () async {
              final step = _next!;
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              final ctx = router.routerDelegate.navigatorKey.currentContext;
              if (ctx != null) await step.onTap(ctx);
            }),
          ],
          SizedBox(height: 8.spMin),
          _secondary('Done', () async => Navigator.of(context).pop()),
        ];
    }
  }

  String _yesLabel() => switch (widget.command.kind) {
        VoiceCommandKind.savePlace => 'Yes, save it',
        VoiceCommandKind.sendAlert => 'Yes, send it',
        VoiceCommandKind.checkIn => 'Yes, check in',
        _ => 'Yes',
      };

  Widget _primary(final String label, final Future<void> Function() onTap) {
    return SizedBox(
      height: 52.spMin,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _secondary(final String label, final Future<void> Function() onTap) {
    return SizedBox(
      height: 48.spMin,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          side: const BorderSide(color: Color(0xFFD9D6D0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
