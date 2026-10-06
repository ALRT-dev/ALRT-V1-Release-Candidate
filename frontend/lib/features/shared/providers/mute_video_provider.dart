import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/providers/states/mute_video_provider_state.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';

final providerOfMuteVideo =
    StateNotifierProvider<MuteVideoProvider, MuteVideoProviderState>(
      (ref) => MuteVideoProvider(
        ref: ref,
        state: MuteVideoProviderState(),
      ),
    );

class MuteVideoProvider extends StateNotifier<MuteVideoProviderState> {
  MuteVideoProvider({
    required final Ref ref,
    required final MuteVideoProviderState state,
  }) : _ref = ref,
       super(state);

  final Ref _ref;
  SharedPreferencesRepository get _sharedPrefRepository =>
      _ref.read(providerOfSharedPreferencesRepository);

  /// Saves the [MuteVideoProvider.isMuted] value to the local storage.
  Future<void> saveMuteValueToLocalStorage() {
    return _sharedPrefRepository.saveBool(
      key: SharedPrefsKey.isVideoMuted,
      value: state.isMuted,
    );
  }

  /// Loads the [MuteVideoProvider.isMuted] value from the local storage.
  Future<void> loadMuteValueFromLocalStorage() async {
    final result = await _sharedPrefRepository.getBool(
      key: SharedPrefsKey.isVideoMuted,
    );
    if (!mounted) return;

    result.whenSuccess((val) {
      if (val != null) updateIsMuted(val);
    });
  }

  /// Updates [MuteVideoProvider.isMuted] to the given [isMuted].
  void updateIsMuted(final bool isMuted) {
    state = state.copyWith(
      isMuted: isMuted,
    );
    saveMuteValueToLocalStorage();
  }

  /// Toggles the value of [MuteVideoProvider.isMuted].
  void toggleIsMuted() {
    updateIsMuted(!state.isMuted);
  }
}
