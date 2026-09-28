import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A friendly, context-specific explanation shown BEFORE a purchase
/// screen, never instead of it. Explains exactly what limit was hit and
/// why, then offers one clear next action in the colour of the plan that
/// answers it ([identity]: Individual for personal limits). Returns true
/// if [onPrimary] was tapped and it popped true, false otherwise.
Future<bool> showAlrtPlusUpsellSheet({
  required final BuildContext context,
  required final IconData icon,
  required final String title,
  required final String message,
  required final String primaryLabel,
  required final Future<bool> Function(BuildContext) onPrimary,
  final LinearGradient? iconGradient,
  final String secondaryLabel = 'Not now',
  final PlanIdentity identity = PlanIdentity.individual,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _UpsellSheetContent(
      icon: icon,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      iconGradient: iconGradient,
      secondaryLabel: secondaryLabel,
      identity: identity,
    ),
  );
  return result ?? false;
}

class _UpsellSheetContent extends StatefulWidget {
  const _UpsellSheetContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    required this.iconGradient,
    required this.secondaryLabel,
    required this.identity,
  });

  final PlanIdentity identity;
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final Future<bool> Function(BuildContext) onPrimary;
  final LinearGradient? iconGradient;
  final String secondaryLabel;

  @override
  State<_UpsellSheetContent> createState() => _UpsellSheetContentState();
}

class _UpsellSheetContentState extends State<_UpsellSheetContent> {
  bool _busy = false;

  Future<void> _handlePrimary() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await widget.onPrimary(context);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(22.spMin, 14.spMin, 22.spMin, 22.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3DFEA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 18.spMin),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 52.spMin,
                height: 52.spMin,
                decoration: BoxDecoration(
                  color: widget.iconGradient == null
                      ? widget.identity.tint
                      : null,
                  gradient: widget.iconGradient,
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconGradient == null
                      ? widget.identity.accent
                      : Colors.white,
                  size: 26.spMin,
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: AlrtPlusStyle.ink,
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 13.5.spMin,
                height: 1.55,
                color: AlrtPlusStyle.inkSoft,
              ),
            ),
            SizedBox(height: 20.spMin),
            PlanCta(
              label: widget.primaryLabel,
              identity: widget.identity,
              busy: _busy,
              onPressed: _handlePrimary,
            ),
            SizedBox(height: 8.spMin),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(
                widget.secondaryLabel,
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  fontWeight: FontWeight.w600,
                  color: AlrtPlusStyle.inkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon convenience — the four upsell moments share one visual language,
/// so callers just name which limit was hit.
abstract final class AlrtPlusUpsellIcons {
  static const savedLocation = LucideIcons.mapPin;
  static const hostCircle = LucideIcons.users;
  static const seatsFull = LucideIcons.userX;
  static const circleLimit = LucideIcons.layoutGrid;
}
