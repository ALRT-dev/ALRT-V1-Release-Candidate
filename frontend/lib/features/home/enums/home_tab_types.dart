import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum HomeTab {
  map,
  search,
  list,
  notifications,
  family,
  profile;

  /// The title of the tab.
  String get title {
    switch (this) {
      case HomeTab.map:
        return 'Map';
      case HomeTab.search:
        return 'Search';
      case HomeTab.list:
        return 'ALRT';
      case HomeTab.notifications:
        return 'Alerts';
      case HomeTab.family:
        return 'Family';
      case HomeTab.profile:
        return 'Profile';
    }
  }

  /// The icon data for the tab.
  IconData get iconData {
    switch (this) {
      case HomeTab.map:
        return LucideIcons.mapPin;
      case HomeTab.search:
        return LucideIcons.search;
      case HomeTab.list:
        return LucideIcons.list;
      case HomeTab.notifications:
        return LucideIcons.bell;
      case HomeTab.family:
        return LucideIcons.users;
      case HomeTab.profile:
        return LucideIcons.userRound;
    }
  }
}

/// The default tab that the user will see when they land on the home screen.
const kDefaultHomeTab = HomeTab.map;
