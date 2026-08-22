import 'package:hazard_app/others/app_flavor_types.dart';

class AppInfo {
  /// The name of the app.
  final appName = 'ALRT';

  /// The package name of the app.
  final appId = 'com.safetyalrt.alrt';

  /// The flavor that the app is running on.
  final flavor = AppFlavor.prod;
}

class DevAppInfo extends AppInfo {
  @override
  String get appName => '[DEV] ALRT';

  @override
  String get appId => '${super.appId}.dev';

  @override
  AppFlavor get flavor => AppFlavor.dev;
}
