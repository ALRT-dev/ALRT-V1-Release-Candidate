import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hazard_app/features/shared/services/firebase_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazard_app/features/shared/providers/app_info_provider.dart';
import 'package:hazard_app/features/shared/providers/base_url_provider.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/firebase_options.dart';
import 'package:hazard_app/others/app.dart';
import 'package:hazard_app/others/app_flavor_types.dart';

class AppBootstrap {
  /// Initializes the app with the given [flavor].
  AppBootstrap({required this.flavor}) {
    _onInit();
  }

  final AppFlavor flavor;

  void _onInit() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Future.wait([
      _initializeEasyLocalization(),
      _initializeFirebase(),
      _loadEnvironmentVariables(),
      _initializeGoogleFonts(),
      _initializeHomeWidget(),
    ]);

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

  Future<void> _loadEnvironmentVariables() async {
    return runAsyncCall(
      name: 'loadEnvironmentVariables',
      future: () async {
        await dotenv.load(fileName: '.env');
      },
      onError: (_) {},
    );
  }

  Future<void> _initializeGoogleFonts() async {
    return runAsyncCall(
      name: 'initializeGoogleFonts',
      future: () async {
        await GoogleFonts.pendingFonts([
          GoogleFonts.bebasNeue(),
        ]);
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

  Future<void> _initializeFirebase() async {
    return runAsyncCall(
      name: 'initializeFirebase',
      future: () async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        // Ask ALRT's callable enforces App Check, so the attestation has
        // to be registered before anything calls it.
        await FirebaseSessionService.initializeAppCheck();
      },
      onError: (_) {},
    );
  }
}
