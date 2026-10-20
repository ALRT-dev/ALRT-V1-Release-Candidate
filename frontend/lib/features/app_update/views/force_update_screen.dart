import 'package:flutter/material.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full screen and not dismissible: this build is below the minimum the
/// backend supports (GET /api/app/version-policy). MyApp shows it in place
/// of every route, so there is nothing behind it to go back to. The one
/// action opens the store page the backend named.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, this.storeUrl, this.openUrl});

  final String? storeUrl;

  /// Tests replace the launcher; the app opens the store externally.
  final Future<bool> Function(Uri uri)? openUrl;

  Future<void> _open() async {
    final url = storeUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await (openUrl ??
          (u) => launchUrl(u, mode: LaunchMode.externalApplication))(uri);
    } catch (_) {
      // Nothing else to offer: the store is the only way forward.
    }
  }

  // Prototype "ForceUpdate" board. Plain sizes (no ScreenUtil): this
  // screen can be shown before anything else is set up, and its widget
  // test pumps it on its own.
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _tile = Color(0xFFFFF1E8);
  static const _noteBg = Color(0xFFF0EEEA);
  static const _noteInk = Color(0xFF3A3A42);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _tile,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    size: 34,
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Please update ALRT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  storeUrl == null
                      ? 'This version of ALRT is no longer supported. Open '
                            'your app store and update ALRT to keep receiving '
                            'alerts.'
                      : 'This version of ALRT is no longer supported. Update '
                            'to keep receiving alerts.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _noteBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'If you are in immediate danger, call your local '
                    'emergency number.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: _noteInk,
                    ),
                  ),
                ),
                if (storeUrl != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      key: const Key('force-update-open-store'),
                      onPressed: _open,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Update ALRT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
