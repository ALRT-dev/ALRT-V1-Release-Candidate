import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The live SOS events and journeys THIS phone started, kept on the
/// device. Location leaves a phone only by the owner's action on that
/// phone: after a restart or a group switch the app resumes a live SOS
/// loop or a journey's point loop only for ids in here, never for one the
/// same account started on another phone (that phone sees it as mine, but
/// sends nothing unless the person chooses to share from it).
///
/// Every read and write fails quietly: without storage the app simply
/// does not resume, which is the safe side.
class OwnedLiveShares {
  const OwnedLiveShares();

  static const _sosKey = 'family_owned_live_sos_ids';
  static const _journeyKey = 'family_owned_journey_ids';

  Future<Set<String>> sosIds() => _read(_sosKey);
  Future<void> addSos(final String id) => _change(_sosKey, add: id);
  Future<void> removeSos(final String id) => _change(_sosKey, remove: id);

  Future<Set<String>> journeyIds() => _read(_journeyKey);
  Future<void> addJourney(final String id) => _change(_journeyKey, add: id);
  Future<void> removeJourney(final String id) =>
      _change(_journeyKey, remove: id);

  Future<Set<String>> _read(final String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(key) ?? const <String>[]).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _change(
    final String key, {
    final String? add,
    final String? remove,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = (prefs.getStringList(key) ?? const <String>[]).toSet();
      if (add != null) ids.add(add);
      if (remove != null) ids.remove(remove);
      await prefs.setStringList(key, ids.toList());
    } catch (_) {
      // No storage: nothing resumes later, the safe side.
    }
  }
}

final providerOfOwnedLiveShares = Provider<OwnedLiveShares>(
  (ref) => const OwnedLiveShares(),
);
