import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_lists_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hold-to-send Family SOS. Sends a location snapshot + SOS to the circle only —
/// ALRT never contacts authorities, and the screen says so with 000 one tap
/// away the whole time.
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

  /// The sender's own choice, made before triggering — SOS must never
  /// assume live location sharing is wanted (low battery, or any other
  /// reason to send without a continuous stream). Defaults on: most
  /// people want live sharing in an emergency, but it is a real,
  /// visible, changeable choice, not an unconditional side effect.
  bool _liveLocationEnabled = true;

  @override
  void initState() {
    super.initState();
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _fireSos();
    });
    Future.microtask(
      () => ref.read(providerOfFamily.notifier).loadSosLists(),
    );
  }

  @override
  void dispose() {
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
    final selectedList =
        sosLists.where((l) => l.id == _selectedListId).firstOrNull;
    final targetLabel = selectedList == null
        ? 'all $memberCount members of $circleName'
        : 'the ${selectedList.memberIds.length} people on '
              '${selectedList.name}';

    return Scaffold(
      backgroundColor: FamilyColors.sosDarkRed,
      body: SafeArea(
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
                    ? (_liveLocationEnabled
                          ? 'Your live location is now shared with '
                                '${selectedList?.name ?? circleName}. They can '
                                'watch your movements on the map until you stand '
                                'down from the Family tab, for up to 4 hours.'
                          : '${selectedList?.name ?? circleName} has been '
                                'alerted. Your location is not being shared live.')
                    : (_liveLocationEnabled
                          ? 'Sends an SOS and your live location '
                                'to $targetLabel.'
                          : 'Sends an SOS to $targetLabel. Your live '
                                'location will not be shared.'),
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
                  onPressed: () => context.push(FamilySosListsScreen.route),
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
                _liveLocationToggleBuilder(),
              ],
              const Spacer(),
              _sent ? _sentIndicatorBuilder() : _holdButtonBuilder(),
              SizedBox(height: 14.spMin),
              if (!_sent)
                Text(
                  'Keep holding to send',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13.spMin,
                  ),
                ),
              const Spacer(),
              _whatThisDoesBuilder(emergencyNumber),
              SizedBox(height: 14.spMin),
              _callEmergencyButtonBuilder(emergencyNumber),
              SizedBox(height: 8.spMin),
              TextButton(
                onPressed: () => context.pop(),
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
      onTap: () => setState(() {
        _listTouched = true;
        _selectedListId = id;
      }),
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

  /// The sender's explicit choice, made before triggering — never an
  /// assumed default the sender didn't see. Off is a real option, not a
  /// hidden path: low battery, or any other reason not to start a
  /// continuous location stream, stays fully supported.
  Widget _liveLocationToggleBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 4.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Share live location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _liveLocationEnabled,
            activeThumbColor: Colors.white,
            activeTrackColor: FamilyColors.safeGreen,
            inactiveThumbColor: Colors.white.withValues(alpha: 0.7),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            onChanged: (value) =>
                setState(() => _liveLocationEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _holdButtonBuilder() {
    return GestureDetector(
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

  Widget _callEmergencyButtonBuilder(final String emergencyNumber) {
    return SizedBox(
      height: 52.spMin,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: FamilyColors.sosRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
        ),
        onPressed: () => launchUrl(Uri.parse('tel:$emergencyNumber')),
        icon: Icon(Icons.phone, size: 20.spMin),
        label: Text(
          'Call $emergencyNumber',
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _cancelHold() {
    if (_holdController.isAnimating) {
      _holdController.reverse();
    }
  }

  void _fireSos() async {
    HapticFeedback.heavyImpact();
    final sos = await ref
        .read(providerOfFamily.notifier)
        .triggerSos(
          sosListId: _selectedListId,
          isLive: _liveLocationEnabled,
        );
    if (!mounted) return;
    if (sos != null) {
      setState(() => _sent = true);
    } else {
      context.showErrorToast(
        message: 'Could not send the SOS. Check your connection and retry.',
      );
      _holdController.reset();
    }
  }
}
