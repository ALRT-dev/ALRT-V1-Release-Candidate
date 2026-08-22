import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The circle the family tab is currently scoped to.
///
/// `null` means "my first circle" — the backend default — so single-circle
/// users never notice this exists. Every family API call reads this at the
/// repository boundary, which keeps the whole feature single-sourced.
final providerOfSelectedCircleId =
    NotifierProvider<SelectedCircleIdNotifier, String?>(
      SelectedCircleIdNotifier.new,
    );

class SelectedCircleIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(final String? circleId) => state = circleId;
}
