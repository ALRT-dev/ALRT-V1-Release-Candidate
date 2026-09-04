import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/utils/invite_code.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan a family invite QR. Resolves to the canonical `ALRT-XXXXX` code the
/// moment one is read, or null if the person backs out.
///
/// The QR the host shows (FamilyInviteScreen) encodes the bare invite code
/// and nothing else, so this is the whole "scan to join" path: read the
/// code, hand it to the same join flow a typed code goes through. No deep
/// link, no website, no App Links / Universal Links, no store involvement -
/// it works identically on a sideloaded TEST APK and a store build.
///
/// The camera starts when this sheet opens, i.e. only after the person
/// tapped "Scan a code"; the OS permission prompt appears at that moment.
/// A denied permission is explained in place, with typing the code offered
/// as the equal alternative.
Future<String?> showFamilyInviteScannerSheet(final BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FamilyInviteScannerSheet(),
  );
}

class _FamilyInviteScannerSheet extends StatefulWidget {
  const _FamilyInviteScannerSheet();

  @override
  State<_FamilyInviteScannerSheet> createState() =>
      _FamilyInviteScannerSheetState();
}

class _FamilyInviteScannerSheetState extends State<_FamilyInviteScannerSheet> {
  // QR only: an invite is never anything else, and ignoring other formats
  // keeps the detector from firing on stray barcodes in frame.
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _done = false;

  /// What was last read that is NOT an invite code, so the person is told
  /// why nothing happened instead of watching a silent viewfinder.
  String? _rejectedHint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(final BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;
      final code = parseInviteCode(raw);
      if (code != null) {
        _done = true;
        _controller.stop();
        Navigator.of(context).pop(code);
        return;
      }
      if (mounted) {
        setState(
          () => _rejectedHint = raw.startsWith('http')
              ? 'That QR is a web link, not an ALRT invite code.'
              : 'That QR isn\'t an ALRT invite code. Ask the host to open '
                  'Family → Add member and show you their code.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.spMin),
          Container(
            width: 40.spMin,
            height: 4.spMin,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.spMin, 14.spMin, 8.spMin, 6.spMin),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan the invite QR',
                        style: TextStyle(
                          fontSize: 18.spMin,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 3.spMin),
                      Text(
                        'Point the camera at the code on the host\'s phone.',
                        style: TextStyle(
                          fontSize: 13.spMin,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(LucideIcons.x, size: 22.spMin),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.spMin, 8.spMin, 20.spMin, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.spMin),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) =>
                          _errorBuilder(context, error),
                      placeholderBuilder: (context) => Container(
                        color: const Color(0xFF15131C),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Viewfinder frame: where to hold the code.
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 220.spMin,
                          height: 220.spMin,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(18.spMin),
                          ),
                        ),
                      ),
                    ),
                    if (_rejectedHint != null)
                      Positioned(
                        left: 12.spMin,
                        right: 12.spMin,
                        bottom: 12.spMin,
                        child: Container(
                          padding: EdgeInsets.all(12.spMin),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(12.spMin),
                          ),
                          child: Text(
                            _rejectedHint!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5.spMin,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 14.spMin),
              child: SizedBox(
                width: double.infinity,
                height: 48.spMin,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: FamilyColors.indigo,
                    backgroundColor: FamilyColors.indigoLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(LucideIcons.pencil, size: 18.spMin),
                  label: Text(
                    'Type the code instead',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Camera problems, said plainly. Permission is the common one: name the
  /// fix (Settings) and the equal alternative (typing the code).
  Widget _errorBuilder(
    final BuildContext context,
    final MobileScannerException error,
  ) {
    final String title;
    final String body;
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        title = 'Camera access is off';
        body = 'ALRT can\'t scan without the camera. Allow camera access for '
            'ALRT in your phone\'s Settings, then try again - or just type '
            'the code in below. Nothing else needs the camera.';
      case MobileScannerErrorCode.unsupported:
        title = 'No camera available';
        body = 'This device can\'t scan codes. Type the code in below instead.';
      case MobileScannerErrorCode.controllerAlreadyInitialized:
      case MobileScannerErrorCode.controllerDisposed:
      case MobileScannerErrorCode.controllerInitializing:
      case MobileScannerErrorCode.controllerNotAttached:
      case MobileScannerErrorCode.controllerUninitialized:
      case MobileScannerErrorCode.genericError:
        title = 'The camera couldn\'t start';
        body = 'Close this and try Scan a code again, or type the code in '
            'below instead.';
    }
    return Container(
      color: const Color(0xFF15131C),
      padding: EdgeInsets.all(24.spMin),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            error.errorCode == MobileScannerErrorCode.permissionDenied
                ? LucideIcons.eyeOff
                : LucideIcons.circleAlert,
            color: Colors.white,
            size: 40.spMin,
          ),
          SizedBox(height: 14.spMin),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.spMin,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.spMin),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5.spMin,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
