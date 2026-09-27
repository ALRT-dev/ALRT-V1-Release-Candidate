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
///
/// This shares the APP only. It is not how someone joins a family circle:
/// that is a Family invite code (FamilyInviteScreen), which never involves
/// a website link at all.
Future<void> showShareAlrtSheet(final BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareAlrtSheet(link: AppLinks.shareApp),
  );
}

/// Share ALRT with someone standing next to you (QR) or anywhere else
/// (copy the link, or hand it to the OS share sheet).
///
/// [link] is null on a TEST build: a sideloaded TEST APK must never send
/// a recipient to the production website or a store, so the sheet says so
/// (the TEST APK is sent directly) instead of showing a QR or a share
/// button (AppLinks.shareAppLinkForFlavor).
class ShareAlrtSheet extends StatelessWidget {
  const ShareAlrtSheet({super.key, required this.link});

  final String? link;

  @override
  Widget build(BuildContext context) {
    final link = this.link;
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
              link == null
                  ? 'Tell someone about the app.'
                  : 'They scan this, or you send them the link.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.mediumGrey,
              ),
            ),
            12.hSizedBox,
            _notAnInviteNoteBuilder(),
            20.hSizedBox,
            if (link == null)
              _testBuildNoticeBuilder()
            else ...[
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
                    data: link,
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
              _linkRowBuilder(context, link),
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
                  onPressed: () => _share(context, link),
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
          ],
        ),
      ),
    );
  }

  /// Said on the sheet itself, because testers mixed the two up: this is
  /// about the app, not about joining a circle.
  Widget _notAnInviteNoteBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 10.spMin),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(12.spMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 16.spMin, color: AppColors.mediumGrey),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Text(
              'This shares the app itself. To add someone to your family '
              'circle, use Family → Add member and give them an invite code.',
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.4,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TEST builds have nothing safe to link to: the app they run is a
  /// sideloaded internal build, and the production site/stores are off
  /// limits from here.
  Widget _testBuildNoticeBuilder() {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: const Color(0xFFF5C9A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.science_outlined,
            size: 20.spMin,
            color: AppColors.orange,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              'TEST build: sharing links are switched off. This build is '
              'not in the stores and must not point anyone at them. To get '
              'another tester on board, send them the TEST APK directly.',
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.45,
                color: const Color(0xFF7A3E00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The link itself, always visible and one tap to copy, so it can be
  /// pasted anywhere the OS share sheet does not reach.
  Widget _linkRowBuilder(final BuildContext context, final String link) {
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
              AppLinks.shareAppProductionDisplay,
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
            onTap: () => _copy(context, link),
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

  void _copy(final BuildContext context, final String link) {
    Clipboard.setData(ClipboardData(text: link));
    AnalyticsService.appShared(from: 'profile_copy');
    context.showSuccessToast(message: 'Link copied');
  }

  Future<void> _share(final BuildContext context, final String link) async {
    AnalyticsService.appShared(from: 'profile_share');
    await SharePlus.instance.share(
      ShareParams(
        text: '$_shareMessage\n\n$link',
        subject: 'ALRT — safety alerts for where you are',
      ),
    );
  }
}
