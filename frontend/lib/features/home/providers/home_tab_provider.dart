import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';

/// Provider that will handle the state of current [HomeTab].
final providerOfHomeTab =
    StateProvider.autoDispose<HomeTab>((ref) => kDefaultHomeTab);
