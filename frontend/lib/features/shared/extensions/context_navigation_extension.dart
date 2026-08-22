import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ContextNavigationExt on BuildContext {
  /// Pops all the routes until it reaches the given [route].
  void popUntilRoute<T>(final String route, [final T? result]) {
    final router = GoRouter.of(this);
    while (router
            .routerDelegate.currentConfiguration.matches.last.matchedLocation !=
        route) {
      if (!canPop()) return;
      pop<T>(result);
    }
  }
}
