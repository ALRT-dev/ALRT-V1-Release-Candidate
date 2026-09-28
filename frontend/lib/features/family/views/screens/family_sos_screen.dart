import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/services/family_location_service.dart';
import 'package:hazard_app/features/family/services/sos_api.dart';
import 'package:hazard_app/features/family/services/location_fix.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:hazard_app/features/family/utils/sos_preview.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'dart:async';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_lists_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

/// Hold-to-send Family SOS. Sends a location snapshot + SOS to the circle only —
/// ALRT never contacts authorities; this screen states that and tells the
/// sender to call their local emergency number themselves if life or
/// property is in danger (product-owner instruction 2026-08-30 removed the
/// in-app one-tap call button).
class FamilySosScreen extends ConsumerStatefulWidget {
  const FamilySosScreen({super.key});

  static const route = '/family-sos';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilySosScreenState();
}

class _FamilySosScreenState extends ConsumerState<FamilySosScreen>
    with SingleTickerProviderStateMixin {
  static const _holdDuration = Duration(seconds: 3);

  late final AnimationController _holdController = AnimationController(
    vsync: this,
    duration: _holdDuration,
  );

  bool _sent = false;

  /// §28: the selected preset. Null = the implicit "Everyone" (whole
  /// circle). Pre-selects the default list once lists load, until the
  /// user explicitly picks a row.
  String? _selectedListId;
  bool _listTouched = false;

  /// The sender's explicit location choice (review follow-up): No
  /// location, Share location once, Share live location. Null until the
  /// phone has been asked where it is; then a visible, changeable default:
  /// live when there is a CURRENT fix and the person shares location in
  /// this group, otherwise No location. A last-known point is never
  /// chosen for them.
  SosLocationChoice? _choice;
  LocationFix? _fix;

  /// Who the backend says the SOS reaches now (the send re-checks).
  SosPreview? _preview;
  bool _previewFailed = false;
  String? _previewKey;

  bool get _liveLocationEnabled => _choice == SosLocationChoice.live;

  @override
  void initState() {
    super.initState();
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _fireSos();
    });
    Future.microtask(() async {
      await ref.read(providerOfFamily.notifier).loadSosLists();
      _loadPreview();
    });
    _resolveFix();
  }

  Future<void> _resolveFix() async {
    final fix = await ref.read(providerOfFamilyLocationService).resolveFix();
    if (!mounted) return;
    final level = ref.read(providerOfFamily).circle?.me?.sharingLevel;
    final sharesHere =
        level == FamilySharingLevel.precise ||
        level == FamilySharingLevel.approximate;
    setState(() {
      _fix = fix;
      _choice ??= fix.isCurrent && sharesHere
          ? SosLocationChoice.live
          : SosLocationChoice.none;
    });
  }

  Future<void> _loadPreview() async {
    final key = _selectedListId ?? '';
    _previewKey = key;
    final result = await ref
        .read(providerOfSosApi)
        .preview(sosListId: _selectedListId);
    if (!mounted || _previewKey != key) return;
    setState(() {
      _preview = result.isSuccess ? result.success : null;
      _previewFailed = result.isFailure;
    });
  }

  @override
  void dispose() {
    _returnTimer?.cancel();
    _holdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = ref.watch(
      providerOfFamily.select((s) => (s.circle?.others.length ?? 0)),
    );
    final circleName = ref.watch(
      providerOfFamily.select((s) => s.circle?.name ?? 'your family circle'),
    );
    final sosLists = ref.watch(providerOfFamily.select((s) => s.sosLists));
    // Global app: the local emergency number, never a hard-coded 000.
    final emergencyNumber = ref.watch(providerOfEmergencyNumber);

    // Default list preselected until the user picks one themselves.
    if (!_listTouched && _selectedListId == null) {
      final defaultList = sosLists.where((l) => l.isDefault).firstOrNull;
      if (defaultList != null) _selectedListId = defaultList.id;
    }
    final selectedList = sosLists
        .where((l) => l.id == _selectedListId)
        .firstOrNull;
    final others = ref.watch(
      providerOfFamily.select((s) => s.circle?.others ?? const <FamilyMember>[]),
    );
    final preview = sosPreview(
      others: others,
      list: selectedList,
      live: _liveLocationEnabled,
    );
    final targetLabel = selectedList == null
        ? 'all $memberCount members of $circleName'
        : 'the ${selectedList.memberIds.length} people on '
              '${selectedList.name}';

    return Scaffold(
      backgroundColor: FamilyColors.sosDarkRed,
      body: SafeArea(
        // Scrolls on short phones / large text instead of overflowing; on
        // taller screens the Spacers still centre the hold button.
        child: LayoutBuilder(
          builder: (final context, final constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(24.spMin),
                  child: Column(
                    children: [
                      SizedBox(height: 20.spMin),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.spMin,
                          vertical: 6.spMin,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.spMin),
                          border: Border.all(
                            color: FamilyColors.sosRed.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          'FAMILY SOS',
                          style: TextStyle(
                            color: const Color(0xFFFCA5A5),
                            fontSize: 12.spMin,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.spMin),
                      Text(
                        _sent ? 'SOS sent' : 'Alert your circle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.spMin,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.spMin),
                      Text(
                        _sent
                            ? switch (_choice) {
                                SosLocationChoice.live =>
                                  'Your live location is now shared with '
                                      'the people this SOS went to, until you '
                                      'end it, for up to 4 hours.',
                                SosLocationChoice.once =>
                                  'The people this SOS went to were sent your '
                                      'location once. It won\'t update.',
                                _ =>
                                  'The people this SOS went to were alerted '
                                      'without your location.',
                              }
                            : switch (_choice) {
                                SosLocationChoice.live =>
                                  'Sends an SOS and your live location to '
                                      '$targetLabel.',
                                SosLocationChoice.once =>
                                  'Sends an SOS and your location once to '
                                      '$targetLabel. It won\'t update.',
                                _ =>
                                  'Sends an SOS to $targetLabel, without '
                                      'your location.',
                              },
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14.spMin,
                        ),
                      ),
                      if (!_sent && sosLists.isNotEmpty) ...[
                        SizedBox(height: 16.spMin),
                        _presetRowBuilder(
                          id: null,
                          name: 'Everyone in $circleName',
                          count: memberCount,
                        ),
                        for (final list in sosLists)
                          _presetRowBuilder(
                            id: list.id,
                            name: list.name,
                            count: list.memberIds.length,
                          ),
                      ],
                      if (!_sent) ...[
                        SizedBox(height: 6.spMin),
                        TextButton(
                          onPressed: () =>
                              context.push(FamilySosListsScreen.route),
                          child: Text(
                            sosLists.isEmpty
                                ? 'Set up who your SOS reaches'
                                : 'Manage lists',
                            style: TextStyle(
                              fontSize: 12.spMin,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.85),
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white54,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.spMin),
                        _locationChoiceBuilder(),
                        SizedBox(height: 10.spMin),
                        _previewBuilder(preview),
                      ],
                      const Spacer(),
                      _sent
                          ? _sentIndicatorBuilder()
                          : _blockerBuilder(preview, sosLists, emergencyNumber) ??
                                _holdButtonBuilder(),
                      SizedBox(height: 14.spMin),
                      if (!_sent && _blockerBuilder(preview, sosLists, emergencyNumber) == null)
                        Text(
                          'Keep holding to send',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13.spMin,
                          ),
                        ),
                      const Spacer(),
                      _whatThisDoesBuilder(emergencyNumber),
                      SizedBox(height: 8.spMin),
                      TextButton(
                        // Returns to whichever screen this SOS was started from —
                        // today, always the Family hub's own SOS tile, since that's
                        // the only place this screen is reachable from.
                        onPressed: _sent ? _goToFamily : () => context.pop(),
                        child: Text(
                          _sent ? 'Done' : 'Cancel',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 15.spMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// §28: large single-select rows — radio, name, count. No checkboxes,
  /// no expansion, no counting on this screen.
  Widget _presetRowBuilder({
    required final String? id,
    required final String name,
    required final int count,
  }) {
    final isSelected = _selectedListId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _listTouched = true;
          _selectedListId = id;
          _preview = null;
          _previewFailed = false;
        });
        _loadPreview();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 8.spMin),
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 12.spMin,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isSelected ? 0.16 : 0.07),
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20.spMin,
              color: Colors.white,
            ),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$count ${count == 1 ? 'person' : 'people'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12.5.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// No location / Share location once / Share live location, with the
  /// phone's real location state above them. "Once" with live off is
  /// always labelled as a point being sent, never as "not shared".
  Widget _locationChoiceBuilder() {
    final fix = _fix;
    final level = ref.read(providerOfFamily).circle?.me?.sharingLevel;
    final suburbOnly = level != null && level != FamilySharingLevel.precise;
    final unavailableReason = fix?.reason;
    final onceEnabled = fix != null && fix.hasPoint;
    final liveEnabled =
        fix != null &&
        unavailableReason != LocationUnavailableReason.servicesOff &&
        unavailableReason != LocationUnavailableReason.permissionDenied;
    final onceText = fix == null
        ? 'Checking your location…'
        : fix.isCurrent
        ? 'Where you are now, sent once. It won\'t update.'
        : fix.kind == LocationFixKind.lastKnown
        ? 'Your last known location, from ${fix.ageLabel}. It won\'t update.'
        : 'Not available: ${fix.statusLine}';
    final liveText = fix == null
        ? 'Checking your location…'
        : !liveEnabled
        ? 'Not available: ${fix.statusLine}'
        : fix.isCurrent
        ? 'Updates while your SOS runs, up to 4 hours.'
        : 'Starts when your phone finds you, then updates while your SOS '
              'runs, up to 4 hours.';
    Widget segment(
      final SosLocationChoice value,
      final String label, {
      required final bool enabled,
    }) {
      final selected = _choice == value;
      return Expanded(
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: InkWell(
            key: Key('sos-loc-${value.name}'),
            borderRadius: BorderRadius.circular(10.spMin),
            onTap: enabled && !_sent
                ? () => setState(() => _choice = value)
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.spMin),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.spMin),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? FamilyColors.sosDarkRed : Colors.white,
                  fontSize: 12.5.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final chosenText = switch (_choice) {
      null => 'Checking your location…',
      SosLocationChoice.none => 'No location: your SOS is sent without where you are.',
      SosLocationChoice.once => 'Share location once: $onceText',
      SosLocationChoice.live => 'Share live location: $liveText',
    };
    return Container(
      key: const Key('sos-location-choice'),
      width: double.infinity,
      padding: EdgeInsets.all(10.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fix == null ? 'Checking your location…' : fix.statusLine,
            key: const Key('sos-location-status'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.spMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.spMin),
          Row(
            children: [
              segment(SosLocationChoice.none, 'No location', enabled: true),
              SizedBox(width: 6.spMin),
              segment(SosLocationChoice.once, 'Once', enabled: onceEnabled),
              SizedBox(width: 6.spMin),
              segment(SosLocationChoice.live, 'Live', enabled: liveEnabled),
            ],
          ),
          SizedBox(height: 6.spMin),
          Text(
            chosenText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.spMin,
              height: 1.35,
            ),
          ),
          if (suburbOnly)
            Text(
              'Suburb only, never an exact pin: your sharing setting.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.spMin,
              ),
            ),
          if (fix != null && !fix.hasPoint)
            Text(
              'You can still send your SOS without location.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.spMin,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  /// Before sending: exactly who the backend says it reaches now, who is
  /// left out and why, and what location they get. Eligible is never
  /// presented as "delivered".
  Widget _previewBuilder(final LocalSosPreview local) {
    Widget line(final IconData icon, final String label, final String text) =>
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.spMin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16.spMin, color: Colors.white),
              SizedBox(width: 8.spMin),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$label ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: text),
                    ],
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.spMin,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
    final p = _preview;
    final names = p == null
        ? local.recipientsLine
        : joinNames(p.recipients.map((r) => r.name).toList());
    final excluded = p?.excluded ?? const <SosPreviewPerson>[];
    final limited = p?.recipients.where((r) => r.deliveryLimited).toList() ??
        const <SosPreviewPerson>[];
    final locationLine = switch (_choice) {
      null => 'Checking…',
      SosLocationChoice.none => 'None.',
      SosLocationChoice.once =>
        _fix?.kind == LocationFixKind.lastKnown
            ? 'Your last known location (${_fix!.ageLabel}), once.'
            : 'Where you are now, once. It won\'t update.',
      SosLocationChoice.live =>
        'Your live location, updating until you end the SOS (up to 4 hours).',
    };
    return Container(
      key: const Key('sos-preview'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 10.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(
            Icons.people_alt_outlined,
            'Goes to:',
            p == null && !_previewFailed
                ? '$names (checking who can receive it…)'
                : names.isEmpty
                ? 'No one yet'
                : names,
          ),
          if (_previewFailed)
            line(
              Icons.info_outline,
              'Not checked:',
              'ALRT will check who can receive it when you send.',
            ),
          if (excluded.isNotEmpty)
            line(
              Icons.person_off_outlined,
              'Not included:',
              excluded
                  .map((e) => '${e.name} (${excludedReason(e.reason)})')
                  .join(', '),
            ),
          if (p?.preset?.state == 'outdated')
            line(
              Icons.warning_amber_rounded,
              'List out of date:',
              '${p!.preset!.removedCount} ${p.preset!.removedCount == 1 ? 'person has' : 'people have'} left since you made "${p.preset!.name}".',
            ),
          line(Icons.place_outlined, 'Location:', locationLine),
          if (limited.isNotEmpty)
            line(
              Icons.notifications_off_outlined,
              'May not be notified:',
              '${joinNames(limited.map((r) => r.name).toList())} (no phone '
                  'registered for alerts). They will see it in ALRT.',
            ),
          Padding(
            padding: EdgeInsets.only(top: 2.spMin),
            child: Text(
              'Notifications can be delayed or missed; ALRT can\'t promise '
              'delivery.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11.5.spMin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// What replaces the hold button when an SOS can't go anywhere yet, or
  /// null when it can. Each case gets its own fix: invite people only when
  /// there are none; open the exact list when a list needs repair.
  Widget? _blockerBuilder(
    final LocalSosPreview local,
    final List<FamilySosList> lists,
    final String emergencyNumber,
  ) {
    final p = _preview;
    if (p == null) {
      // Not checked yet (or failed): only block when there is plainly
      // nobody else in the group. The send re-checks everything.
      return local.isEmpty ? _nobodyToReachBuilder(emergencyNumber) : null;
    }
    switch (p.state) {
      case SosPreviewState.ok:
      case SosPreviewState.senderNoAccess:
        return null;
      case SosPreviewState.noPeople:
        return _nobodyToReachBuilder(emergencyNumber);
      case SosPreviewState.noneEligible:
        return _blockPanel(
          key: 'sos-none-eligible',
          title: 'No one here can receive an SOS right now',
          body:
              'Everyone ${_selectedListId == null ? 'in this group' : 'on this list'} '
              'needs ALRT +, or a group plan that is active. If you are in '
              'immediate danger, call $emergencyNumber.',
          action: _selectedListId == null ? null : 'Edit this list',
          onAction: _selectedListId == null
              ? null
              : () => _openList(lists, _selectedListId!),
        );
      case SosPreviewState.presetInvalid:
        final preset = p.preset;
        return _blockPanel(
          key: 'sos-preset-invalid',
          title: '"${preset?.name ?? 'This list'}" needs fixing',
          body:
              '${preset?.state == 'empty' ? 'No one on it is in this group any more.' : 'It names people from another group.'} '
              'Edit it, or choose "Everyone" above. If you are in immediate '
              'danger, call $emergencyNumber.',
          action: 'Edit "${preset?.name ?? 'this list'}"',
          onAction: preset == null ? null : () => _openList(lists, preset.id),
        );
    }
  }

  /// Opens THIS list for editing (never a blank new list).
  Future<void> _openList(final List<FamilySosList> lists, final String id) async {
    final list = lists.where((l) => l.id == id).firstOrNull;
    if (list == null) {
      context.showErrorToast(message: 'That list could not be found.');
      return;
    }
    await context.push(
      FamilySosListEditScreen.route,
      extra: FamilySosListEditScreenArgs(list: list),
    );
    if (!mounted) return;
    await ref.read(providerOfFamily.notifier).loadSosLists();
    _loadPreview();
  }

  Widget _blockPanel({
    required final String key,
    required final String title,
    required final String body,
    final String? action,
    final VoidCallback? onAction,
  }) {
    return Container(
      key: Key(key),
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.spMin,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5.spMin,
              height: 1.4,
            ),
          ),
          if (action != null && onAction != null) ...[
            SizedBox(height: 12.spMin),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FamilyColors.sosDarkRed,
                shape: const StadiumBorder(),
              ),
              child: Text(action),
            ),
          ],
        ],
      ),
    );
  }

  /// No one to send to: say so before the hold, never after it.
  Widget _nobodyToReachBuilder(final String emergencyNumber) {
    return Container(
      key: const Key('sos-nobody'),
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        children: [
          Text(
            'Add someone first',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.spMin,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            'Your SOS needs at least one other person to reach. If you are '
            'in immediate danger, call $emergencyNumber.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5.spMin,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.spMin),
          FilledButton(
            onPressed: () => context.push(FamilyInviteScreen.route),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FamilyColors.sosDarkRed,
              shape: const StadiumBorder(),
            ),
            child: const Text('Invite someone'),
          ),
        ],
      ),
    );
  }

  Widget _holdButtonBuilder() {
    return GestureDetector(
      key: const Key('sos-hold-button'),
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _holdController.forward(from: 0);
      },
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _holdController,
        builder: (context, child) {
          return SizedBox(
            width: 210.spMin,
            height: 210.spMin,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 210.spMin,
                  height: 210.spMin,
                  child: CircularProgressIndicator(
                    value: _holdController.value,
                    strokeWidth: 6,
                    color: const Color(0xFFFCA5A5),
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                Container(
                  width: 180.spMin,
                  height: 180.spMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: FamilyColors.sosRed.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42.spMin,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'HOLD 3 SEC',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12.spMin,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sentIndicatorBuilder() {
    return Container(
      width: 180.spMin,
      height: 180.spMin,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: FamilyColors.safeGreen,
      ),
      child: Icon(Icons.check_rounded, color: Colors.white, size: 90.spMin),
    );
  }

  Widget _whatThisDoesBuilder(final String emergencyNumber) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT THIS DOES',
            style: TextStyle(
              color: const Color(0xFFFCA5A5),
              fontSize: 11.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            'SOS notifies your family only. ALRT does not contact emergency '
            'services or monitor this alert. If life or property is in '
            'danger, call $emergencyNumber.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.spMin,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _cancelHold() {
    if (_holdController.isAnimating) {
      _holdController.reverse();
    }
  }

  /// True from the moment the hold completes until the server has
  /// answered, so a second hold (or a stuck animation) can never raise a
  /// second SOS.
  bool _sending = false;

  /// The auto-return, kept so Done and dispose can cancel it: an
  /// un-cancelled timer once navigated a second time after Done and left
  /// the person on the map tab.
  Timer? _returnTimer;
  bool _navigated = false;

  void _fireSos() async {
    if (_sending || _sent) return;
    _sending = true;
    HapticFeedback.heavyImpact();
    final notifier = ref.read(providerOfFamily.notifier);
    FamilySosEvent? sos;
    try {
      sos = await notifier.triggerSos(
        sosListId: _selectedListId,
        location: _choice ?? SosLocationChoice.none,
        fix: _fix,
      );
      if (!mounted) return;
      if (sos == null) {
        // The answer may have been lost after the server acted. Ask before
        // offering a retry, so a retry can never raise a second SOS.
        sos = await notifier.findMyActiveSos();
        if (!mounted) return;
      }
    } finally {
      _sending = false;
    }
    if (sos != null) {
      setState(() => _sent = true);
      _returnToFamilyAfterSend();
    } else {
      _holdController.reset();
      // Nobody to reach, a list from another group, or no access here:
      // each gets its own answer. Only an unknown failure says "retry".
      final refusal = AccessRefusal.fromError(
        ref.read(providerOfFamily).sosTriggerState.error,
      );
      if (refusal != null) {
        await showAccessRefusalSheet(context, ref, refusal);
        return;
      }
      context.showErrorToast(
        message: 'Could not send the SOS. Check your connection and retry.',
      );
    }
  }

  /// Product decision 2026-09-09: once the server has confirmed the SOS,
  /// the sender goes straight back to the Family screen, where the red
  /// "Your SOS is active" strip and its Open action live. The tick shows
  /// for a moment; no further tap is needed (Done still works sooner).
  void _returnToFamilyAfterSend() {
    _returnTimer?.cancel();
    _returnTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || !_sent) return;
      _goToFamily();
    });
  }

  /// Exactly once: choose the Family tab (the tab provider is kept alive,
  /// so the choice survives this screen going away), then leave. Leaving
  /// comes first in the try so a failure to set the tab can never leave
  /// the tick on screen.
  void _goToFamily() {
    if (_navigated) return;
    _navigated = true;
    _returnTimer?.cancel();
    try {
      ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
    } catch (_) {
      // The tab is a courtesy; leaving the screen is the requirement.
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        HomeScreen.route,
        extra: HomeScreenArgs(initialTab: HomeTab.family),
      );
    }
  }
}
