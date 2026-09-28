import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/search/providers/main_search_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/saved_location_gate.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_upsell_sheet.dart';

/// The one "Save this location" tap handler, shared by every Subscribe
/// button on the Search tab. It runs the provider's decision, shows the
/// explanation sheet and the ALRT + Individual paywall (personal limits
/// point to Individual, never to a group plan) from the tapped screen's own
/// context, and then saves the location the person was in the middle of
/// saving, all without a restart. Every outcome ends in something visible.
bool _saveInFlight = false;

/// True while a save/remove (and any sheet or paywall it opened) is in
/// progress, so rapid taps cannot start a second one.
bool get isSaveLocationInFlight => _saveInFlight;

Future<void> handleSaveLocationTap(
  final BuildContext context,
  final WidgetRef ref,
) async {
  if (_saveInFlight) return;
  _saveInFlight = true;
  try {
    await _handleSaveLocationTap(context, ref);
  } finally {
    _saveInFlight = false;
  }
}

Future<void> _handleSaveLocationTap(
  final BuildContext context,
  final WidgetRef ref,
) async {
  final notifier = ref.read(providerOfMainSearch.notifier);
  var outcome = await notifier.toggleSubscription();
  if (!context.mounted) return;

  if (outcome is SaveLocationNeedsPlus) {
    final purchased = await showAlrtPlusUpsellSheet(
      context: context,
      icon: AlrtPlusUpsellIcons.savedLocation,
      title: 'One saved place on ALRT Free',
      message:
          'ALRT Free includes $kFreeSavedLocationsLimit saved place as well '
          'as where you are. ALRT + Individual gives you unlimited saved '
          'places. Family and Group plans don\'t change this.',
      primaryLabel: 'See ALRT + Individual',
      onPrimary: (ctx) => ctx
          .push<bool>(
            AlrtPlusPaywallScreen.route,
            extra: const AlrtPlusPaywallArgs(
              reason: AlrtPlusPaywallReason.savedLocation,
            ),
          )
          .then((value) => value ?? false),
    );
    if (!purchased || !context.mounted) return;
    // Entitled now: finish the save that started this, on the same screen.
    outcome = await notifier.toggleSubscription();
    if (!context.mounted) return;
    if (outcome is SaveLocationNeedsPlus) {
      context.showErrorToast(
        message: outcome.fromServer
            ? 'Purchase confirmed. We\'re updating your access. Try again '
                  'in a moment.'
            : 'Purchase confirmed. We\'re updating your access. Try again '
                  'in a moment.',
      );
      return;
    }
  }

  switch (outcome) {
    case SaveLocationSaved(:final name):
      context.showSuccessToast(
        message: name == null || name.isEmpty
            ? 'Location saved. Alerts for it will reach you.'
            : 'Saved $name. Alerts for it will reach you.',
      );
    case SaveLocationRemoved():
      context.showSuccessToast(message: 'Location removed.');
    case SaveLocationCouldNotCheck(:final message):
      if (message.isNotEmpty) context.showErrorToast(message: message);
    case SaveLocationFailed(:final message):
      context.showErrorToast(
        message: message.isEmpty
            ? 'Could not save this location. Please try again.'
            : message,
      );
    case SaveLocationNeedsPlus():
      break; // handled above
  }
}
