import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/auth/providers/service_providers.dart';
import 'package:hazard_app/features/auth/services/auth_service.dart';
import 'package:hazard_app/features/profile/providers/states/profile_provider_state.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_badges_card.dart';
import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/providers/user_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/services/media_service.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';
import 'package:hazard_app/features/shared/services/firebase_session_service.dart';
import 'package:image_picker/image_picker.dart';

final providerOfProfile =
    StateNotifierProvider.autoDispose<ProfileProvider, ProfileProviderState>(
      (ref) => ProfileProvider(
        ref: ref,
        state: const ProfileProviderState(),
      ),
    );

class ProfileProvider extends StateNotifier<ProfileProviderState> {
  ProfileProvider({
    required final Ref ref,
    required final ProfileProviderState state,
  }) : _ref = ref,
       super(state) {
    _initializeProfilePicture();
    _listenToSocketEvents();

    _ref.onDispose(() {
      _showUpdateProfilePictureButtonTimer?.cancel();
    });
  }

  final Ref _ref;
  AuthService get _authService => _ref.read(providerOfAuthService);
  MediaService get _mediaService => _ref.read(providerOfMediaService);
  UserService get _userService => _ref.read(providerOfUserService);
  UserSocketManager get _userSocketManager =>
      _ref.read(providerOfUserSocketManager);

  /// Timer to hide the update profile picture button after a delay.
  Timer? _showUpdateProfilePictureButtonTimer;

  // Only fetch 3 items for preview.
  final pageSize = 3;

  /// Initializes the profile picture in the state.
  void _initializeProfilePicture() {
    final loggedInUser = _ref.read(providerOfLoggedInUser);
    updateProfilePictureInTheState(loggedInUser?.processedProfilePicture);
  }

  /// Listens to socket events and updates the logged-in user accordingly.
  void _listenToSocketEvents() {
    final xpUpdatesListener = _userSocketManager.userXpUpdateStream.listen(
      (xpPoints) {
        _ref
            .read(providerOfLoggedInUser.notifier)
            .update((user) => user?.copyWith(xpPoints: xpPoints));
      },
    );

    final reliabilityUpdatesListener = _userSocketManager
        .userReliabilityUpdateStream
        .listen(
          (reliabilityScore) {
            _ref
                .read(providerOfLoggedInUser.notifier)
                .update(
                  (user) => user?.copyWith(reliabilityScore: reliabilityScore),
                );
          },
        );

    final upvotesReceivedCountListener = _userSocketManager
        .userUpvotesReceivedCountUpdateStream
        .listen(
          (upvotesReceivedCount) {
            _ref
                .read(providerOfLoggedInUser.notifier)
                .update(
                  (user) => user?.copyWith(
                    upvotesReceivedCount: upvotesReceivedCount,
                  ),
                );
          },
        );

    // A badge arriving while the app is open gets celebrated where the
    // person actually is, and the profile shelf is refreshed behind it.
    final badgeEarnedListener = _userSocketManager.badgeEarnedStream.listen(
      (badge) {
        _ref.invalidate(providerOfXpSummary);
        final context = _ref.read(providerOfGlobalNavigatorKey).currentContext;
        if (context == null || !context.mounted) return;
        BadgeEarnedBanner.show(
          context: context,
          name: badge.name,
          description: badge.description,
        );
      },
    );

    // Cancel the subscriptions when the provider is disposed.
    _ref.onDispose(() {
      xpUpdatesListener.cancel();
      reliabilityUpdatesListener.cancel();
      upvotesReceivedCountListener.cancel();
      badgeEarnedListener.cancel();
    });
  }

  /// Updates the profile picture of the user, picking it from [source]
  /// first (defaults to the gallery).
  Future<void> updateProfilePicture({
    final ImageSource source = ImageSource.gallery,
  }) async {
    final isSelected = await pickProfilePicture(source: source);
    if (!isSelected) return;
    if (!mounted) return;

    if (state.profilePicture?.source != AlrtMediaSource.file) return;

    state = state.copyWith(
      profilePictureUpdateState: ProfilePictureUpdateState.loading(),
    );

    updateShowUpdateProfilePictureButton(false);

    final result = await _userService.updateUserProfilePicture(
      profilePicture: state.profilePicture!,
      onSendProgress: (final sent, final total) {
        state = state.copyWith(
          profilePictureUpdateState: ProfilePictureUpdateState.loading(
            progress: (sent / total),
          ),
        );
      },
    );
    if (!mounted) return;

    result.when(
      (updatedUser) {
        state = state.copyWith(
          profilePictureUpdateState: ProfilePictureUpdateState.success(
            updatedUser,
          ),
        );

        // Update the logged-in user in the global state.
        // Don't use the updatedUser.processedProfilePicture directly because it will use networkUrl
        // which may cause unnecessary network calls. Instead, use the one from state.
        _ref
            .read(providerOfLoggedInUser.notifier)
            .update(
              (user) => user?.copyWith(
                processedProfilePicture: state.profilePicture,
              ),
            );
      },
      (error) {
        state = state.copyWith(
          profilePictureUpdateState: ProfilePictureUpdateState.error(error),
        );
        updateProfilePictureInTheState(null);
      },
    );
  }

  /// Picks a new profile picture using the media service, from [source]
  /// (defaults to the gallery).
  Future<bool> pickProfilePicture({
    final ImageSource source = ImageSource.gallery,
  }) async {
    final result = await _mediaService.pickImage(source: source);
    if (!mounted) return false;

    return result.when(
      (pickedMedia) {
        if (pickedMedia == null) return false;
        updateProfilePictureInTheState(pickedMedia);
        return true;
      },
      (error) {
        return false;
      },
    );
  }

  /// Logout the current user.
  Future<void> logout() async {
    state = state.copyWith(
      logoutState: const LogoutState.loading(),
    );

    final result = await _authService.logout();
    if (!mounted) return;

    result.when(
      (_) {
        // Drop the Firebase session too, or the next person to sign in on
        // this phone inherits the previous user's Ask ALRT identity.
        FirebaseSessionService.signOut();
        state = state.copyWith(
          logoutState: const LogoutState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          logoutState: LogoutState.error(error),
        );
      },
    );
  }

  /// Deletes the current user's account.
  Future<void> deleteAccount() async {
    state = state.copyWith(
      deleteAccountState: const DeleteAccountState.loading(),
    );

    final result = await _userService.deleteAccount();
    if (!mounted) return;

    await result.when(
      (_) async {
        // Clear local tokens after successful account deletion
        await _authService.logout();
        if (!mounted) return;

        state = state.copyWith(
          deleteAccountState: const DeleteAccountState.success(),
        );
      },
      (error) async {
        state = state.copyWith(
          deleteAccountState: DeleteAccountState.error(error),
        );
      },
    );
  }

  /// Updates the [ProfileProviderState.profilePicture] with the given [profilePicture].
  void updateProfilePictureInTheState(final AlrtMedia? profilePicture) {
    state = state.copyWith(profilePicture: profilePicture);
  }

  /// Updates the [ProfileProviderState.showUpdateProfilePictureButton] with the given [show].
  void updateShowUpdateProfilePictureButton(final bool show) {
    state = state.copyWith(showUpdateProfilePictureButton: show);

    if (show) {
      _showUpdateProfilePictureButtonTimer?.cancel();
      _showUpdateProfilePictureButtonTimer = Timer(
        const Duration(seconds: 2),
        () {
          if (!mounted) return;
          updateShowUpdateProfilePictureButton(false);
        },
      );
    } else {
      _showUpdateProfilePictureButtonTimer?.cancel();
    }
  }
}
