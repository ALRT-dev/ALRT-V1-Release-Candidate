import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show appFlavor;

/// True in debug runs and in test builds (flavour "dev"), never in live
/// builds. Gates tester tools such as simulated travel on a route, so a route
/// and its en-route alerts can be checked without driving it.
bool get isTestBuild => kDebugMode || appFlavor == 'dev';
