import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Joining is free and unlimited: any number of groups, any time, with a
/// code. Only HOSTING is an ALRT+ moment, so only the create path may show
/// the paywall. Both entry points (the empty state and the group switcher)
/// go through here so the rules can't drift apart.
Future<void> showJoinGroupSheet(
  final BuildContext context,
  final WidgetRef ref,
) {
  return _showFieldSheet(
    context: context,
    title: 'Join with a code',
    subtitle: 'Got an invite code? Enter it here. Joining is always free, '
        'and you can be in as many groups as you like.',
    hint: 'e.g. ALRT-7F3K2',
    buttonLabel: 'Join group',
    capitalization: TextCapitalization.characters,
    onSubmit: (final code) {
      if (code.isEmpty) {
        context.showErrorToast(message: 'Enter an invite code first');
        return false;
      }
      ref.read(providerOfFamily.notifier).join(code: code);
      return true;
    },
  );
}

Future<void> showCreateGroupSheet(
  final BuildContext context,
  final WidgetRef ref,
) {
  return _showFieldSheet(
    context: context,
    title: 'Name your group',
    subtitle: 'e.g. Nixon Family, Netball Mums, Site Crew. Your ALRT+ seats '
        'can be split across up to 4 groups you host.',
    hint: 'Group name',
    buttonLabel: 'Create a group',
    onSubmit: (final name) {
      if (name.isEmpty) {
        context.showErrorToast(message: 'Give your group a name first');
        return false;
      }
      _createGated(context, ref, name);
      return true;
    },
  );
}

/// ALRT+ moment: hosting needs a subscription (1-month free trial). The
/// paywall shows only here, never on a join.
Future<void> _createGated(
  final BuildContext context,
  final WidgetRef ref,
  final String name,
) async {
  final isPlus = await ref.read(providerOfAlrtPlus.future);
  if (!isPlus) {
    if (!context.mounted) return;
    final subscribed = await context.push<bool>(AlrtPlusPaywallScreen.route);
    if (subscribed != true) return;
  }
  ref.read(providerOfFamily.notifier).createCircle(name: name);
}

/// A rounded single-field input sheet; keyboard-safe. Returns via [onSubmit],
/// which closes the sheet by returning true.
Future<void> _showFieldSheet({
  required final BuildContext context,
  required final String title,
  required final String subtitle,
  required final String hint,
  required final String buttonLabel,
  required final bool Function(String value) onSubmit,
  final TextCapitalization capitalization = TextCapitalization.words,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) => _FieldSheetBody(
      title: title,
      subtitle: subtitle,
      hint: hint,
      buttonLabel: buttonLabel,
      capitalization: capitalization,
      onSubmit: onSubmit,
    ),
  );
}

class _FieldSheetBody extends StatefulWidget {
  const _FieldSheetBody({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.buttonLabel,
    required this.capitalization,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final String hint;
  final String buttonLabel;
  final TextCapitalization capitalization;
  final bool Function(String value) onSubmit;

  @override
  State<_FieldSheetBody> createState() => _FieldSheetBodyState();
}

class _FieldSheetBodyState extends State<_FieldSheetBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.onSubmit(_controller.text.trim())) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.spMin,
        20.spMin,
        20.spMin,
        MediaQuery.of(context).viewInsets.bottom + 20.spMin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 18.spMin, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.spMin),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.5,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 16.spMin),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: widget.capitalization,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: FamilyColors.v31Page,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.spMin),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 14.spMin),
          SizedBox(
            width: double.infinity,
            height: 50.spMin,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FamilyColors.indigo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.spMin),
                ),
              ),
              onPressed: _submit,
              child: Text(
                widget.buttonLabel,
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
