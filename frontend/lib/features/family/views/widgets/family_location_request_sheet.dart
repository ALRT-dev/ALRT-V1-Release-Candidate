import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the consent sheet for a "where are you" location request.
///
/// This is the heart of ALRT's location posture: nothing is shared until the
/// member taps "Share once", and declining sends nothing back.
Future<void> showFamilyLocationRequestSheet({
  required final BuildContext context,
  required final String requestId,
  final String? requesterName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FamilyLocationRequestSheet(
      requestId: requestId,
      requesterName: requesterName,
    ),
  );
}

class FamilyLocationRequestSheet extends ConsumerStatefulWidget {
  const FamilyLocationRequestSheet({
    super.key,
    required this.requestId,
    this.requesterName,
  });

  final String requestId;
  final String? requesterName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyLocationRequestSheetState();
}

class _FamilyLocationRequestSheetState
    extends ConsumerState<FamilyLocationRequestSheet> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final requester = widget.requesterName ?? 'A family member';

    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(12.spMin),
        padding: EdgeInsets.all(24.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.spMin),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 56.spMin,
              height: 56.spMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: FamilyColors.indigoLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.mapPin,
                color: FamilyColors.indigo,
                size: 28.spMin,
              ),
            ),
            SizedBox(height: 16.spMin),
            Text(
              '$requester asked where you are',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.spMin,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Share a one-time snapshot of your current location with your '
              'circle? It expires after 1 hour and is never updated '
              'automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.45,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 20.spMin),
            SizedBox(
              height: 52.spMin,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: _isSharing ? null : _shareOnce,
                child: _isSharing
                    ? SizedBox(
                        width: 20.spMin,
                        height: 20.spMin,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Share once',
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 8.spMin),
            SizedBox(
              height: 48.spMin,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: _isSharing ? null : _decline,
                child: Text(
                  'Not now',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Declining sends nothing. ALRT does not track you and never '
              'shares your location without this tap.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.spMin,
                height: 1.4,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareOnce() async {
    setState(() => _isSharing = true);
    final shared = await ref
        .read(providerOfFamily.notifier)
        .respondToLocationRequest(requestId: widget.requestId, share: true);
    if (!mounted) return;
    Navigator.of(context).pop();
    shared
        ? context.showSuccessToast(
            message: 'Snapshot shared. It expires in 1 hour.',
          )
        : context.showErrorToast(
            message:
                'Could not share your location. Check location permissions '
                'and try again.',
          );
  }

  Future<void> _decline() async {
    // Fire-and-forget: declining should feel instant and sends nothing.
    ref
        .read(providerOfFamily.notifier)
        .respondToLocationRequest(requestId: widget.requestId, share: false);
    Navigator.of(context).pop();
  }
}
