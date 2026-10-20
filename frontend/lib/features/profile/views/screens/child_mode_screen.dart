import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/providers/child_mode_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Child mode: a parent's switch on a child's phone.
///
/// A restriction that helps, not a security boundary: the PIN stops the
/// casual case. Prototype "ChildMode" board: white header with back arrow,
/// one status card, the PIN field, then an orange "Turn on" (or a white
/// "Turn off" while it is on).
class ChildModeScreen extends ConsumerStatefulWidget {
  const ChildModeScreen({super.key});

  static const route = '/child-mode';

  @override
  ConsumerState<ChildModeScreen> createState() => _ChildModeScreenState();
}

class _ChildModeScreenState extends ConsumerState<ChildModeScreen> {
  final _pinController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _toggle(final bool turnOn) async {
    if (_busy) return;
    final notifier = ref.read(providerOfChildMode.notifier);
    final pin = _pinController.text.trim();
    setState(() => _busy = true);
    if (turnOn) {
      await notifier.enable(pin: pin);
      if (!mounted) return;
      _pinController.clear();
      setState(() => _busy = false);
      return;
    }

    final settings = ref.read(providerOfChildMode);
    final ok = await notifier.disable(pin: settings.hasPin ? pin : null);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      _pinController.clear();
    } else {
      context.showErrorToast(
        message: pin.isEmpty
            ? 'Enter the PIN to turn child mode off.'
            : 'That PIN did not match.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(providerOfChildMode);
    final isOn = settings.isOn;
    final needsPinToTurnOff = isOn && settings.hasPin;
    final showPin = !isOn || needsPinToTurnOff;

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(title: 'Child mode'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 32.spMin),
              children: [
                ProfileCard(
                  children: [
                    Text(
                      isOn ? 'Child mode is on' : 'Child mode is off',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const ProfileMutedText(
                      'Map, SOS and check-ins only. Report is hidden. Set by '
                      'a parent or guardian.',
                    ),
                  ],
                ),
                if (showPin) ...[
                  SizedBox(height: 14.spMin),
                  TextField(
                    key: const Key('child-mode-pin'),
                    controller: _pinController,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: needsPinToTurnOff ? 'PIN' : 'PIN (optional)',
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.spMin,
                        vertical: 14.spMin,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.spMin),
                        borderSide: const BorderSide(
                          color: ProfilePageKit.hairline,
                          width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.spMin),
                        borderSide: const BorderSide(
                          color: ProfilePageKit.hairline,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.spMin),
                        borderSide: const BorderSide(
                          color: AppColors.orange,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 14.spMin),
                ProfileButton(
                  key: const Key('child-mode-toggle'),
                  label: isOn ? 'Turn off' : 'Turn on',
                  kind: isOn
                      ? ProfileButtonKind.secondary
                      : ProfileButtonKind.primary,
                  busy: _busy,
                  onPressed: () => _toggle(!isOn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
