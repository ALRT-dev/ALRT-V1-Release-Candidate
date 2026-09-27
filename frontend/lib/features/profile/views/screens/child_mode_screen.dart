import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/child_mode_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Child mode: a parent's switch on a child's phone.
///
/// It is honest about what it is. A restriction that helps, not a security
/// boundary: the PIN stops the casual case and the copy says so rather
/// than implying the phone is locked down.
class ChildModeScreen extends ConsumerStatefulWidget {
  const ChildModeScreen({super.key});

  static const route = '/child-mode';

  @override
  ConsumerState<ChildModeScreen> createState() => _ChildModeScreenState();
}

class _ChildModeScreenState extends ConsumerState<ChildModeScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _toggle(final bool turnOn) async {
    final notifier = ref.read(providerOfChildMode.notifier);
    if (turnOn) {
      await notifier.enable(pin: _pinController.text.trim());
      _pinController.clear();
      return;
    }

    final settings = ref.read(providerOfChildMode);
    if (!settings.hasPin) {
      await notifier.disable();
      return;
    }
    final pin = await _askForPin();
    if (pin == null) return;
    final ok = await notifier.disable(pin: pin);
    if (!mounted) return;
    if (!ok) context.showErrorToast(message: 'That PIN did not match.');
  }

  Future<String?> _askForPin() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter the PIN'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Turn off'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(providerOfChildMode);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8C00), Color(0xFFFF6B01)],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        ),
        title: Text(
          'Child mode',
          style: TextStyle(
            fontSize: 17.spMin,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(18.spMin),
        children: [
          Container(
            padding: EdgeInsets.all(16.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.spMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        settings.isOn ? 'Child mode is on' : 'Child mode',
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Switch(
                      value: settings.isOn,
                      activeTrackColor: AppColors.orange,
                      onChanged: _toggle,
                    ),
                  ],
                ),
                SizedBox(height: 6.spMin),
                Text(
                  'For a phone you have set up for your child. They keep the '
                  'map, alerts near them, SOS and check-ins. Posting a '
                  'community report is turned off, so they are not '
                  'publishing to strangers.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.5,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.spMin),
          if (!settings.isOn) ...[
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.spMin),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PIN (optional)',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.spMin),
                  Text(
                    'Set one and it is asked for before child mode can be '
                    'turned off.',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      height: 1.45,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 10.spMin),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Choose a PIN',
                      filled: true,
                      fillColor: const Color(0xFFF4F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.spMin),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.spMin),
          ],
          Container(
            padding: EdgeInsets.all(14.spMin),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(color: const Color(0xFFFFD9B8)),
            ),
            child: Text(
              'Worth knowing: this is a helpful restriction, not a locked '
              'device. A determined child could reinstall the app or use '
              'another phone. For real device limits, use Screen Time on '
              'iPhone or Family Link on Android.',
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.55,
                color: const Color(0xFF8A4B00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
