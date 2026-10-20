import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  static const _ink = Color(0xFF1C1C1E);
  static const _body = Color(0xFF3A3A42);
  static const _muted = Color(0xFF5C5C66);
  static const _handle = Color(0xFFD9D6D0);
  static const _orange = Color(0xFFE8622A);

  /// Laid out like the boards' refusal sheet (Refusal-SavedPlace): grab
  /// handle, a 22 px title, the plain reason, one orange action and a
  /// quiet "Not now".
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, 12.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 5.spMin,
                decoration: BoxDecoration(
                  color: _handle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: _ink,
              ),
            ),
            SizedBox(height: 10.spMin),
            Text(
              widget.message,
              style: TextStyle(fontSize: 14.spMin, height: 1.5, color: _body),
            ),
            SizedBox(height: 16.spMin),
            Container(
              height: 54.spMin,
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(14.spMin),
                boxShadow: [
                  BoxShadow(
                    color: _orange.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.spMin),
                  onTap: _busy ? null : _handlePrimary,
                  child: Center(
                    child: _busy
                        ? SizedBox(
                            width: 20.spMin,
                            height: 20.spMin,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.primaryLabel,
                            style: TextStyle(
                              fontSize: 16.spMin,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.spMin),
            SizedBox(
              height: 44.spMin,
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: _muted),
                child: Text(
                  widget.secondaryLabel,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                  ),
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
