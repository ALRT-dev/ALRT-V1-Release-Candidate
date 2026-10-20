import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

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

    // The LocationRequest board: a plain sheet, the question, Share once
    // on the family gradient and Not now. Nothing leaves the phone unless
    // Share once is tapped.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 16.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FamilyBoardSheetHandle(),
              SizedBox(height: 14.spMin),
              FamilyBoardSheetTitle(
                title: '$requester asked where you are',
                subtitle:
                    'Share a one-time snapshot of your location? It expires '
                    'after 1 hour. Declining sends nothing.',
              ),
              SizedBox(height: 16.spMin),
              FamilyBoardPrimaryButton(
                label: 'Share once',
                isLoading: _isSharing,
                onPressed: _shareOnce,
              ),
              SizedBox(height: 10.spMin),
              FamilyBoardSecondaryButton(
                label: 'Not now',
                onPressed: _isSharing ? null : _decline,
              ),
            ],
          ),
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
    final error = shared
        ? null
        : ref.read(providerOfFamily.notifier).lastLocationError;
    final root = ref.read(providerOfGlobalNavigatorKey).currentContext;
    Navigator.of(context).pop();
    final target = root;
    if (target == null || !target.mounted) return;
    if (shared) {
      target.showSuccessToast(
        message: 'Snapshot shared. It expires in 1 hour.',
      );
    } else if (error != null && target.mounted) {
      await showFamilyActionError(target, ref, error);
    } else {
      target.showErrorToast(
        message:
            'Could not share your location. Check location permissions '
            'and try again.',
      );
    }
  }

  Future<void> _decline() async {
    // Fire-and-forget: declining should feel instant and sends nothing.
    ref
        .read(providerOfFamily.notifier)
        .respondToLocationRequest(requestId: widget.requestId, share: false);
    final root = ref.read(providerOfGlobalNavigatorKey).currentContext;
    Navigator.of(context).pop();
    if (root != null && root.mounted) {
      root.showSuccessToast(message: 'Declined. Nothing was sent.');
    }
  }
}
