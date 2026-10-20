import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/providers/states/profile_provider_state.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_wrapper.dart';

/// Deleting an account, as on the prototype "DeleteAccount" and
/// "DeleteConfirm" boards: one card ("Changed your mind? You have 30
/// days."), a red "Delete my account" that opens the "Are you sure?" sheet,
/// and "Keep my account".
///
/// Every line matches what the backend does (`requestAccountDeletion`,
/// `executeAccountDeletion`): after 30 days the person's own reports are
/// deleted with the account (not kept anonymously, which the board says),
/// they leave their groups, and a group they host with other people in it
/// starts the 7 day host hand-over.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  static const route = '/delete-account';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  @override
  Widget build(BuildContext context) {
    _listenToDeleteAccountState();

    final isLoading = ref.watch(
      providerOfProfile.select(
        (value) => value.deleteAccountState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(title: 'Delete your account?'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 32.spMin),
              children: [
                ProfileCard(
                  children: [
                    Text(
                      'Changed your mind? You have 30 days.',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const ProfileMutedText(
                      'Sign in any time in the next 30 days to recover '
                      'everything. After 30 days it is permanent: the reports '
                      'you posted are removed, your groups lose you, and a '
                      'group you host starts a 7 day hand-over.',
                    ),
                  ],
                ),
                SizedBox(height: 14.spMin),
                ProfileButton.danger(
                  key: const Key('delete-account'),
                  label: 'Delete my account',
                  busy: isLoading,
                  onPressed: _confirmAndDelete,
                ),
                SizedBox(height: 14.spMin),
                ProfileButton(
                  label: 'Keep my account',
                  kind: ProfileButtonKind.ghost,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Listens to changes in the delete account state.
  void _listenToDeleteAccountState() {
    ref.listen<DeleteAccountState>(
      providerOfProfile.select((value) => value.deleteAccountState),
      (previous, next) {
        next.maybeWhen(
          success: () {
            context.showSuccessToast(
              message: 'Deletion scheduled. You have 30 days to change your '
                  'mind by signing in again.',
            );
            context.go(AppWrapper.route);
          },
          error: (_) => context.showErrorToast(
            message: 'Your account could not be deleted. Try again.',
          ),
          orElse: () {},
        );
      },
    );
  }

  /// The prototype "Are you sure?" sheet (DeleteConfirm), then the
  /// deletion is scheduled.
  Future<void> _confirmAndDelete() async {
    FocusScope.of(context).unfocus();
    final user = ref.read(providerOfLoggedInUser);
    final name = user?.name ?? '';
    final email = user?.email ?? '';

    final confirmed = await showProfileSheet<bool>(
      context: context,
      builder: (sheetContext) => [
        const ProfileSheetTitle(
          title: 'Are you sure?',
          subtitle: 'Your account is scheduled for deletion. You have 30 '
              'days to change your mind by signing in again.',
        ),
        ProfileCard(
          children: [
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 15.spMin, color: AppColors.ink),
                children: [
                  const TextSpan(text: 'Signed in as '),
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (email.isNotEmpty) TextSpan(text: ' · $email'),
                ],
              ),
            ),
            const ProfileMutedText(
              'Places, points and group memberships are removed after 30 '
              'days. Reports you posted are removed too.',
            ),
          ],
        ),
        ProfileButton.danger(
          key: const Key('delete-yes'),
          label: 'Yes, delete my account',
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        ProfileButton(
          key: const Key('delete-no'),
          label: 'No, keep my account',
          kind: ProfileButtonKind.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    ref.read(providerOfProfile.notifier).deleteAccount();
  }
}
