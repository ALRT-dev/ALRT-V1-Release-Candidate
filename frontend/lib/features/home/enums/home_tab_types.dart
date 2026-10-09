import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The six footer destinations in visual order: Map, Alerts, Report (ALRT
/// logo), Ready, Family, Me.
///
/// Search was removed in the V3.1 footer redesign (search lives in the Map
/// search bar). Ready is new.
enum HomeTab {
  map,
  notifications,
  list,
  ready,
  family,
  profile;

  /// The label shown beneath the icon in the footer bar.
  String get title {
    switch (this) {
      case HomeTab.map:
        return 'Map';
      case HomeTab.notifications:
        return 'Alerts';
      case HomeTab.list:
        return 'Report';
      case HomeTab.ready:
        return 'Ready';
      case HomeTab.family:
        return 'Family';
      case HomeTab.profile:
        return 'Me';
    }
  }

  /// The icon data for the tab.
  IconData get iconData {
    switch (this) {
      case HomeTab.map:
        return LucideIcons.mapPin;
      case HomeTab.notifications:
        return LucideIcons.bell;
      case HomeTab.list:
        return LucideIcons.list;
      case HomeTab.ready:
        return LucideIcons.shieldCheck;
      case HomeTab.family:
        return LucideIcons.users;
      case HomeTab.profile:
        return LucideIcons.userRound;
    }
  }
}

/// The default tab that the user will see when they land on the home screen.
const kDefaultHomeTab = HomeTab.map;
