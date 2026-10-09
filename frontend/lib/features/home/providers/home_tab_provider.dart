import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';

/// Provider that will handle the state of current [HomeTab].
/// Kept alive on purpose: screens outside the home shell (the SOS send
/// screen, the SOS stand-down, widget and push deep links) choose the tab
/// to land on before the shell is back on screen. An auto-disposed value
/// was dropped in that gap and the user landed on the map.
final providerOfHomeTab = StateProvider<HomeTab>((ref) => kDefaultHomeTab);
