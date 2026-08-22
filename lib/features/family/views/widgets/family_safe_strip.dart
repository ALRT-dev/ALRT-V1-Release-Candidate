import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Tell your family you're safe" strip on the alert detail screen.
/// Shown only to members of a family circle; one tap sends a safe check-in
/// referencing this alert so the whole circle stops worrying.
class FamilySafeStrip extends ConsumerStatefulWidget {
  const FamilySafeStrip({super.key, required this.hazard});

  final Hazard hazard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilySafeStripState();
}

class _FamilySafeStripState extends ConsumerState<FamilySafeStrip> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final hasCircle = ref.watch(
      providerOfFamily.select((s) => s.circle != null),
    );
    if (!hasCircle) return const SizedBox.shrink();

    final isSending = ref.watch(
      providerOfFamily.select((s) => s.checkInState.isLoading),
    );

    return Container(
      margin: EdgeInsets.only(top: 14.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Icon(
            _sent ? LucideIcons.circleCheck : LucideIcons.users,
            color: _sent ? FamilyColors.safeGreen : FamilyColors.indigo,
            size: 22.spMin,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              _sent
                  ? 'Your family has been told you are safe.'
                  : 'Near this alert? Let your family know you are okay.',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                height: 1.35,
              ),
            ),
          ),
          if (!_sent) ...[
            SizedBox(width: 10.spMin),
            SizedBox(
              height: 36.spMin,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                ),
                onPressed: isSending ? null : _sendSafeCheckIn,
                child: isSending
                    ? SizedBox(
                        width: 16.spMin,
                        height: 16.spMin,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "I'm safe",
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sendSafeCheckIn() async {
    final title = widget.hazard.title;
    await ref.read(providerOfFamily.notifier).checkIn(
      message: title == null ? "I'm safe" : 'Safe — near "$title"',
    );
    if (!mounted) return;

    final failed = ref.read(providerOfFamily).checkInState.isError;
    if (!failed) {
      setState(() => _sent = true);
      context.showSuccessToast(message: 'Your circle has been notified.');
    }
  }
}
