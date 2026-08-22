import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// What a shared ALRT link says about the app. Kept short: this travels in
/// a message, so it leads with what the app does, not with a pitch.
const _shareMessage =
    'ALRT sends me safety alerts for where I actually am — bushfire, '
    'flood, road and weather warnings from official sources, plus '
    'reports from people nearby.';

/// Opens the Share ALRT sheet: a QR code to scan and the link to send.
Future<void> showShareAlrtSheet(final BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ShareAlrtSheet(),
  );
}

/// Share ALRT with someone standing next to you (QR) or anywhere else
/// (copy the link, or hand it to the OS share sheet).
class ShareAlrtSheet extends StatelessWidget {
  const ShareAlrtSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 16.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            18.hSizedBox,
            Text(
              'Share ALRT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.spMin,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            6.hSizedBox,
            Text(
              'They scan this, or you send them the link.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.mediumGrey,
              ),
            ),
            20.hSizedBox,
            Center(
              child: Container(
                padding: EdgeInsets.all(16.spMin),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.spMin),
                  border: Border.all(color: AppColors.lightGrey),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColorLight,
                      blurRadius: 12.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: AppLinks.shareApp,
                  size: 200.spMin,
                  backgroundColor: AppColors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            18.hSizedBox,
            _linkRowBuilder(context),
            14.hSizedBox,
            SizedBox(
              height: 50.spMin,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: () => _share(context),
                icon: Icon(LucideIcons.share, size: 18.spMin),
                label: Text(
                  'Share link',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The link itself, always visible and one tap to copy, so it can be
  /// pasted anywhere the OS share sheet does not reach.
  Widget _linkRowBuilder(final BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.spMin,
        vertical: 12.spMin,
      ),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.link, size: 16.spMin, color: AppColors.mediumGrey),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              AppLinks.shareAppDisplay,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _copy(context),
            child: Padding(
              padding: EdgeInsets.all(4.spMin),
              child: Text(
                'Copy',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(final BuildContext context) {
    Clipboard.setData(const ClipboardData(text: AppLinks.shareApp));
    AnalyticsService.appShared(from: 'profile_copy');
    context.showSuccessToast(message: 'Link copied');
  }

  Future<void> _share(final BuildContext context) async {
    AnalyticsService.appShared(from: 'profile_share');
    await SharePlus.instance.share(
      ShareParams(
        text: '$_shareMessage\n\n${AppLinks.shareApp}',
        subject: 'ALRT — safety alerts for where you are',
      ),
    );
  }
}
