import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';

/// "Your sharing level" (SharingLevel board): the location promise, then
/// one radio card per level. The choice saves on tap and applies to the
/// group being viewed.
class FamilySharingLevelScreen extends ConsumerWidget {
  const FamilySharingLevelScreen({super.key});

  static const route = '/family-sharing';

  /// The location promise every sharing surface repeats (rules.json
  /// wording.locationPromise).
  static const locationPromise =
      'Your location leaves your phone only when you send it. No tracking '
      'in the background. A sent location expires after an hour.';

  /// Board title and subtitle for each level, shared with the circle
  /// profile's SHARING LEVEL row so the two never drift apart.
  static (String, String) labelsOf(final FamilySharingLevel level) {
    return switch (level) {
      FamilySharingLevel.precise => (
        'Precise',
        'Exact location when you choose to share',
      ),
      FamilySharingLevel.approximate => (
        'Approximate',
        'Suburb only when you choose to share',
      ),
      FamilySharingLevel.alertsOnly => (
        'Alerts only',
        'Check-ins and SOS, never a location',
      ),
      FamilySharingLevel.off => ('Off', 'Nothing is shared, and nobody can ask'),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      providerOfFamily.select((s) => s.circle?.me?.sharingLevel),
    );
    final isBusy = ref.watch(
      providerOfFamily.select((s) => s.memberUpdateState.isLoading),
    );

    return FamilyBoardScaffold(
      title: 'Your sharing level',
      gap: 10,
      children: [
        const FamilyBoardNote(locationPromise),
        for (final level in FamilySharingLevel.values)
          FamilyBoardRadioCard(
            key: Key('sharing-${level.name}'),
            title: labelsOf(level).$1,
            subtitle: labelsOf(level).$2,
            selected: current == level,
            onTap: isBusy || current == level
                ? null
                : () => ref
                      .read(providerOfFamily.notifier)
                      .updateSharingLevel(level),
          ),
      ],
    );
  }
}
