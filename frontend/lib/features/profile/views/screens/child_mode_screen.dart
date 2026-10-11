import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/child_mode_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Child mode: a parent's switch on a child's phone.
///
/// A restriction that helps, not a security boundary: the PIN stops the
/// casual case. Approved board 9 Oct 2026: plain white app bar, one status
/// card, the optional PIN, one solid CTA.
class ChildModeScreen extends ConsumerStatefulWidget {
  const ChildModeScreen({super.key});

  static const route = '/child-mode';

  @override
  ConsumerState<ChildModeScreen> createState() => _ChildModeScreenState();
}

class _ChildModeScreenState extends ConsumerState<ChildModeScreen> {
  static const _page = Color(0xFFF5F5F7);
  static const _muted = Color(0xFF5C5C66);
  static const _cta = Color(0xFFE8622A);

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
    final isOn = settings.isOn;

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.black),
        ),
        title: Text(
          'Child mode',
          style: TextStyle(
            fontSize: 22.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.spMin),
        children: [
          Container(
            padding: EdgeInsets.all(16.spMin),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOn ? 'Child mode is on' : 'Child mode is off',
                  style: TextStyle(
                    fontSize: 18.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 6.spMin),
                Text(
                  'Map, SOS and check-ins only. Report is hidden. Set by a '
                  'parent or guardian.',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    height: 1.4,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          if (!isOn) ...[
            SizedBox(height: 12.spMin),
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: _cardDecoration(),
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
                  SizedBox(height: 10.spMin),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Choose a PIN',
                      filled: true,
                      fillColor: _page,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.spMin),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.spMin),
          Container(
            height: 54.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _cta,
              borderRadius: BorderRadius.circular(16.spMin),
            ),
            child: Text(
              isOn ? 'Turn off' : 'Turn on',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ).onPressed(() => _toggle(!isOn)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      );
}
