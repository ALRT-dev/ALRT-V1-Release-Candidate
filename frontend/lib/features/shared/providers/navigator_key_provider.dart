import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// A provider that supplies a global [NavigatorState] key for navigation purposes.
final providerOfGlobalNavigatorKey = StateProvider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);
