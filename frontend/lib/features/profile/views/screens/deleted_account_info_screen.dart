import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/providers/service_providers.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/profile/providers/cancel_account_deletion_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_wrapper.dart';

/// Prototype "AccountDeleted" board: days left, Recover my account,
/// Sign out.
class DeletedAccountInfoScreen extends ConsumerStatefulWidget {
  const DeletedAccountInfoScreen({super.key});

  static const route = '/deleted-account-info';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeletedAccountInfoScreenState();
}

class _DeletedAccountInfoScreenState
    extends ConsumerState<DeletedAccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    _listenToCancelDeletionState();

    final scheduledDeletionAt = ref.watch(
      providerOfLoggedInUser.select((value) => value?.scheduledDeletionAt),
    );
    final daysRemaining = scheduledDeletionAt == null
        ? 30
        : scheduledDeletionAt.difference(DateTime.now()).inDays.clamp(0, 30);
    final isLoading = ref.watch(
      providerOfCancelAccountDeletion.select(
        (value) => value.cancelState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(
            title: 'Account scheduled for deletion',
            showBack: false,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 32.spMin),
              children: [
                ProfileCard(
                  children: [
                    Text(
                      daysRemaining == 1
                          ? '1 day left'
                          : '$daysRemaining days left',
                      style: TextStyle(
                        fontSize: 18.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const ProfileMutedText(
                      'Changed your mind? Recover your account and everything '
                      'stays: places, points, your groups.',
                    ),
                  ],
                ),
                SizedBox(height: 14.spMin),
                ProfileButton(
                  key: const Key('recover-account'),
                  label: 'Recover my account',
                  busy: isLoading,
                  onPressed: _handleRecoverAccount,
                ),
                SizedBox(height: 14.spMin),
                ProfileButton(
                  label: 'Sign out',
                  kind: ProfileButtonKind.ghost,
                  onPressed: _handleLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Listens to changes in the cancel deletion state.
  void _listenToCancelDeletionState() {
    ref.listen<CancelAccountDeletionState>(
      providerOfCancelAccountDeletion.select((value) => value.cancelState),
      (previous, next) {
        next.maybeWhen(
          success: () {
            context.showSuccessToast(
              message: 'Your account is recovered.',
            );
            context.go(HomeScreen.route);
          },
          error: (error) {
            context.showErrorToast(
              message: 'Your account could not be recovered. Try again.',
            );
          },
          orElse: () {},
        );
      },
    );
  }

  /// Handles the account recovery process.
  void _handleRecoverAccount() {
    ref.read(providerOfCancelAccountDeletion.notifier).cancelAccountDeletion();
  }

  /// Handles the logout process.
  void _handleLogout() async {
    final result = await ref.read(providerOfAuthService).logout();
    if (!mounted) return;

    result.when(
      (_) => context.go(AppWrapper.route),
      (error) => context.showErrorToast(
        message: 'Could not sign out. Try again.',
      ),
    );
  }
}
