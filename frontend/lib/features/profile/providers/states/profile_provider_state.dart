import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'profile_provider_state.freezed.dart';

@freezed
abstract class ProfileProviderState with _$ProfileProviderState {
  const factory ProfileProviderState({
    /// The profile picture of the user.
    final AlrtMedia? profilePicture,

    /// Whether to show the update profile picture button.
    @Default(false) final bool showUpdateProfilePictureButton,

    /// The state of updating the profile picture.
    @Default(ProfilePictureUpdateState.initial())
    final ProfilePictureUpdateState profilePictureUpdateState,

    /// The state of logging out the user.
    @Default(LogoutState.initial()) final LogoutState logoutState,

    /// The state of deleting the user's account.
    @Default(DeleteAccountState.initial())
    final DeleteAccountState deleteAccountState,
  }) = _ProfileProviderState;
}

@freezed
class LogoutState with _$LogoutState {
  const factory LogoutState.initial() = _LogoutStateInitial;
  const factory LogoutState.loading() = _LogoutStateLoading;
  const factory LogoutState.success() = _LogoutStateSuccess;
  const factory LogoutState.error(
    final AppError error,
  ) = _LogoutStateError;
}

@freezed
class ProfilePictureUpdateState with _$ProfilePictureUpdateState {
  const factory ProfilePictureUpdateState.initial() =
      _ProfilePictureUpdateStateInitial;
  const factory ProfilePictureUpdateState.loading({
    @Default(0.0) final double progress,
  }) = _ProfilePictureUpdateStateLoading;
  const factory ProfilePictureUpdateState.success(
    final AppUser updatedUser,
  ) = _ProfilePictureUpdateStateSuccess;
  const factory ProfilePictureUpdateState.error(
    final AppError error,
  ) = _ProfilePictureUpdateStateError;
}

@freezed
class DeleteAccountState with _$DeleteAccountState {
  const factory DeleteAccountState.initial() = _DeleteAccountStateInitial;
  const factory DeleteAccountState.loading() = _DeleteAccountStateLoading;
  const factory DeleteAccountState.success() = _DeleteAccountStateSuccess;
  const factory DeleteAccountState.error(
    final AppError error,
  ) = _DeleteAccountStateError;
}
