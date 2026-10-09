import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazard_app/features/shared/providers/app_info_provider.dart';
import 'package:hazard_app/features/shared/providers/base_url_provider.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
import 'package:hazard_app/features/map/utils/maps_availability.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/firebase_options.dart';
import 'package:hazard_app/firebase_options_dev.dart';
import 'package:hazard_app/others/app.dart';
import 'package:hazard_app/others/app_flavor_types.dart';
import 'package:hazard_app/others/startup_trace.dart';

class AppBootstrap {
  /// Initializes the app with the given [flavor].
  AppBootstrap({required this.flavor}) {
    _onInit();
  }

  final AppFlavor flavor;

  void _onInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    StartupTrace.captureErrors();
    StartupTrace.mark('bootstrap: start (${flavor.name})');

    await Future.wait([
      _initializeEasyLocalization(),
      _initializeFirebase(),
      _initializeGoogleFonts(),
      _initializeHomeWidget(),
      _initializeMapsAvailability(),
    ]);

    StartupTrace.mark('bootstrap: plugins ready, starting app');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return runApp(
      EasyLocalization(
        supportedLocales: [
          Locale('en'),
          // Spanish returns when full localisation lands (only ~5 strings
          // are translated today).
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        child: ProviderScope(
          overrides: [
            // override the app info provider with dev app info provider if the current flavor is dev
            if (flavor == AppFlavor.dev)
              providerOfAppInfo.overrideWith(
                (ref) => ref.watch(providerOfDevAppInfo),
              ),
            // override the baseUrl with baseUrlDev if the current flavor is dev
            if (flavor == AppFlavor.dev)
              providerOfBaseUrl.overrideWith(
                (ref) => ref.watch(providerOfBaseUrlDev),
              ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  }

  Future<void> _initializeEasyLocalization() async {
    return runAsyncCall(
      name: 'initializeEasyLocalization',
      future: () async {
        await EasyLocalization.ensureInitialized();
      },
      onError: (_) {},
    );
  }

  Future<void> _initializeGoogleFonts() async {
    return runAsyncCall(
      name: 'initializeGoogleFonts',
      future: () async {
        // Never hold the first frame on a slow network: the font falls
        // back to the system face if it has not arrived in time.
        await GoogleFonts.pendingFonts([
          GoogleFonts.figtree(),
          GoogleFonts.bebasNeue(),
        ]).timeout(const Duration(seconds: 5));
      },
      onError: (_) {},
    );
  }

  Future<void> _initializeHomeWidget() async {
    return runAsyncCall(
      name: 'initializeHomeWidget',
      future: () async {
        await HomeWidgetService.initialize();
      },
      onError: (_) {},
    );
  }

  Future<void> _initializeMapsAvailability() async {
    return runAsyncCall(
      name: 'initializeMapsAvailability',
      future: MapsAvailability.initialize,
      onError: (_) {},
    );
  }

  Future<void> _initializeFirebase() async {
    return runAsyncCall(
      name: 'initializeFirebase',
      future: () async {
        // dev must not initialize with the prod Firebase app identity -
        // see V1_RECONCILIATION_REPORT.md §31 for why this was previously
        // wrong on Android regardless of flavor.
        await Firebase.initializeApp(
          options: flavor == AppFlavor.dev
              ? DefaultFirebaseOptionsDev.currentPlatform
              : DefaultFirebaseOptions.currentPlatform,
        );
      },
      onError: (_) {},
    );
  }
}
