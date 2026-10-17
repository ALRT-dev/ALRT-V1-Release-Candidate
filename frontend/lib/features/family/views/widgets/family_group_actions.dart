import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/invite_code.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_invite_scanner_sheet.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Joining and creating groups are free and unlimited (V1 access model).
/// Both entry points (the empty state and the group switcher) go through
/// here so the rules can't drift apart.
///
/// Two equal ways in: type the code, or tap "Scan invite QR" and point the
/// camera at the host's invite QR (which encodes the bare code - see
/// FamilyInviteScreen). Either way the code is normalised by
/// parseInviteCode and handed to the same, unchanged join call. The camera
/// is never touched until "Scan invite QR" is tapped; the permission prompt
/// happens then, not on opening this sheet.
Future<void> showJoinGroupSheet(
  final BuildContext context,
  final WidgetRef ref,
) {
  return _showFieldSheet(
    context: context,
    title: 'Join with a code',
    subtitle:
        'Joining is always free. Ask the host for their invite code or QR.',
    hint: 'ALRT-XXXXX',
    buttonLabel: 'Join group',
    capitalization: TextCapitalization.characters,
    scanButtonLabel: 'Scan invite QR',
    onScan: showFamilyInviteScannerSheet,
    onSubmit: (final raw) {
      if (raw.isEmpty) {
        context.showErrorToast(message: 'Enter or scan an invite code first');
        return false;
      }
      final code = parseInviteCode(raw);
      if (code == null) {
        context.showErrorToast(
          message:
              'That doesn\'t look like an invite code. Codes look like '
              'ALRT-7F3K2 - check it with the host.',
        );
        return false;
      }
      ref.read(providerOfFamily.notifier).join(code: code);
      return true;
    },
  );
}

/// "Scan invite QR": straight to the scanner, no sheet first. Sits beside
/// "I have an invite code" on the onboarding screen and the group switcher.
/// The camera (and its permission prompt) starts only when this is tapped.
/// A valid code goes through the exact same join() as a typed one; nothing
/// is sent for a cancelled or unreadable scan. Errors from the server
/// (unknown / revoked / expired / used-up code, full circle, already a
/// member, group plan full) surface through the screens' existing
/// joinCircleState listeners, word for word.
Future<void> scanInviteQrAndJoin(
  final BuildContext context,
  final WidgetRef ref,
) async {
  final code = await showFamilyInviteScannerSheet(context);
  if (code == null || !context.mounted) return;
  context.showSuccessToast(message: 'Code $code scanned - joining...');
  await ref.read(providerOfFamily.notifier).join(code: code);
}

Future<void> showCreateGroupSheet(
  final BuildContext context,
  final WidgetRef ref,
) {
  return _showFieldSheet(
    context: context,
    title: 'Name your group',
    subtitle: 'Creating a group is free.',
    hint: 'Group name',
    buttonLabel: 'Create group',
    onSubmit: (final name) {
      if (name.isEmpty) {
        context.showErrorToast(message: 'Give your group a name first');
        return false;
      }
      // V1 access model: creating a group is free and there is no limit on
      // how many groups anyone hosts or joins. Paid access is checked on
      // the connection features themselves, per person, by the backend.
      ref.read(providerOfFamily.notifier).createCircle(name: name);
      return true;
    },
  );
}

/// A rounded single-field input sheet; keyboard-safe. Returns via [onSubmit],
/// which closes the sheet by returning true. When [onScan] is given, a
/// secondary "scan" button sits under the field; whatever it returns is put
/// into the field and submitted through the very same [onSubmit].
Future<void> _showFieldSheet({
  required final BuildContext context,
  required final String title,
  required final String subtitle,
  required final String hint,
  required final String buttonLabel,
  required final bool Function(String value) onSubmit,
  final TextCapitalization capitalization = TextCapitalization.words,
  final String? scanButtonLabel,
  final Future<String?> Function(BuildContext context)? onScan,
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
      scanButtonLabel: scanButtonLabel,
      onScan: onScan,
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
    this.scanButtonLabel,
    this.onScan,
  });

  final String title;
  final String subtitle;
  final String hint;
  final String buttonLabel;
  final TextCapitalization capitalization;
  final bool Function(String value) onSubmit;
  final String? scanButtonLabel;
  final Future<String?> Function(BuildContext context)? onScan;

  @override
  State<_FieldSheetBody> createState() => _FieldSheetBodyState();
}

class _FieldSheetBodyState extends State<_FieldSheetBody> {
  final _controller = TextEditingController();
  bool _scanning = false;

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

  /// Opens the scanner. The camera (and its permission prompt) starts only
  /// now, on this tap. A scanned code lands in the field, visibly, and is
  /// then submitted through the same path as a typed one.
  Future<void> _scan() async {
    final onScan = widget.onScan;
    if (onScan == null || _scanning) return;
    setState(() => _scanning = true);
    final code = await onScan(context);
    if (!mounted) return;
    setState(() => _scanning = false);
    if (code == null) return;
    _controller.text = code;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final canScan = widget.onScan != null && widget.scanButtonLabel != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.spMin,
        12.spMin,
        20.spMin,
        // Keyboard or home indicator, whichever is taller, so the Join /
        // Create button is never under either.
        (MediaQuery.viewInsetsOf(context).bottom >
                    MediaQuery.viewPaddingOf(context).bottom
                ? MediaQuery.viewInsetsOf(context).bottom
                : MediaQuery.viewPaddingOf(context).bottom) +
            20.spMin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FamilyBoardSheetHandle(),
          SizedBox(height: 14.spMin),
          FamilyBoardSheetTitle(title: widget.title, subtitle: widget.subtitle),
          SizedBox(height: 16.spMin),
          TextField(
            controller: _controller,
            autofocus: !canScan,
            textCapitalization: widget.capitalization,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.spMin),
                borderSide: const BorderSide(
                  color: AppColors.lightGrey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.spMin),
                borderSide: const BorderSide(
                  color: FamilyColors.indigo,
                  width: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.spMin),
          FamilyBoardPrimaryButton(
            label: widget.buttonLabel,
            onPressed: _submit,
          ),
          if (canScan) ...[
            SizedBox(height: 10.spMin),
            SizedBox(
              width: double.infinity,
              height: 50.spMin,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: FamilyColors.indigo,
                  side: BorderSide(
                    color: FamilyColors.indigo.withValues(alpha: 0.45),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.spMin),
                  ),
                ),
                onPressed: _scanning ? null : _scan,
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 20.spMin,
                ),
                label: Text(
                  widget.scanButtonLabel!,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.spMin),
            Row(
              children: [
                Icon(LucideIcons.info, size: 14.spMin, color: AppColors.grey),
                SizedBox(width: 6.spMin),
                Expanded(
                  child: Text(
                    'The camera is only used while you scan, and only after '
                    'you tap Scan invite QR.',
                    style: TextStyle(
                      fontSize: 11.5.spMin,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4.spMin),
          FamilyBoardGhostButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
