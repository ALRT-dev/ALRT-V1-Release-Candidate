import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/base_url_provider.dart';
import 'package:hazard_app/features/shared/utils/share_alert.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The "Share a link" sheet (prototype board ShareLink, 16 Oct 2026): the
/// public link to this alert, Share (the phone's share sheet), Send to my
/// family circle when there is a group, and Close.
///
/// The public page needs no sign-in. Community reports are served at
/// suburb precision by the backend (public.controller.ts).
Future<void> showShareLinkSheet({
  required final BuildContext context,
  required final Hazard hazard,
  final VoidCallback? onSendToGroup,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    builder: (context) =>
        ShareLinkSheet(hazard: hazard, onSendToGroup: onSendToGroup),
  );
}

class ShareLinkSheet extends ConsumerWidget {
  const ShareLinkSheet({super.key, required this.hazard, this.onSendToGroup});

  final Hazard hazard;

  /// Sends the alert to the user's group. Null hides the button.
  final VoidCallback? onSendToGroup;

  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _handle = Color(0xFFD9D6D0);
  static const _secondaryBorder = Color(0xFFD9D6D0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = hazard.id;
    final url = id == null
        ? null
        : buildAlertShareUrl(
            baseUrl: ref.watch(providerOfBaseUrl),
            hazardId: id,
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, 28.spMin),
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
                borderRadius: BorderRadius.circular(3.spMin),
              ),
            ),
          ),
          SizedBox(height: 14.spMin),
          Text(
            'Share a link',
            style: TextStyle(
              fontSize: 22.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: _ink,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            // The board also promises "keep the Unverified tag"; the public
            // page does not show one yet (backend gap), so that is left out.
            'Public page, no sign-in needed. Community reports share at '
            'suburb precision.',
            style: TextStyle(fontSize: 14.spMin, color: _muted, height: 1.45),
          ),
          SizedBox(height: 14.spMin),
          Container(
            padding: EdgeInsets.all(16.spMin),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.spMin),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hazard.title ?? 'Alert',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                if (url != null) ...[
                  SizedBox(height: 10.spMin),
                  SelectableText(
                    url,
                    style: TextStyle(fontSize: 13.spMin, color: _muted),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.spMin),
          SizedBox(
            height: 54.spMin,
            child: ElevatedButton(
              onPressed: url == null
                  ? null
                  : () => shareAlert(ref: ref, hazard: hazard, from: 'detail'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
              ),
              child: Text(
                'Share',
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (onSendToGroup != null) ...[
            SizedBox(height: 14.spMin),
            SizedBox(
              height: 48.spMin,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                  onSendToGroup!();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: _secondaryBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                child: Text(
                  'Send to my family circle',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 6.spMin),
          SizedBox(
            height: 44.spMin,
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(foregroundColor: _muted),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
