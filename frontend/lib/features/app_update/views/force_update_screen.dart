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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(
                  Icons.system_update_rounded,
                  size: 56,
                  color: AppColors.black,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please update ALRT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1D21),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  storeUrl == null
                      ? 'This version of ALRT is no longer supported. Open '
                            'your app store and update ALRT to keep using it.'
                      : 'This version of ALRT is no longer supported. Update '
                            'to the latest version to keep using it.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF5F5C66),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'If you are in immediate danger, call your local '
                  'emergency number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF5F5C66),
                  ),
                ),
                const Spacer(),
                if (storeUrl != null)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('force-update-open-store'),
                      onPressed: _open,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
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
            ),
          ),
        ),
      ),
    );
  }
}
