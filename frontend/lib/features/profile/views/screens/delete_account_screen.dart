import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/providers/states/profile_provider_state.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_colors.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_gradient_icon.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Deleting an account, told straight: what changes today, what you can
/// still do for 30 days, and what is actually gone for good after that.
/// Every line here matches what the backend does — nothing is claimed
/// that `requestAccountDeletion`/`executeAccountDeletion` don't do.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  static const route = '/delete-account';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmationController = TextEditingController();
  bool _hasConfirmed = false;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listenToDeleteAccountState();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: TextStyle(color: context.onSurface),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        foregroundColor: context.onSurface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningHeader(),
            24.hSizedBox,
            _buildNowSection(),
            16.hSizedBox,
            _buildRecoverySection(),
            24.hSizedBox,
            _buildAfter30DaysSection(),
            24.hSizedBox,
            _buildConfirmationSection(),
            32.hSizedBox,
            _buildDeleteButton(),
            16.hSizedBox,
            _buildCancelButton(),
            16.hSizedBox,
          ],
        ),
      ),
    );
  }

  Widget _buildWarningHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(color: context.cardShadow, blurRadius: 2.0),
        ],
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.triangleAlert,
            color: ProfileColors.dangerAction,
            size: 40.spMin,
          ),
          16.hSizedBox,
          Text(
            'Delete your account?',
            style: TextStyle(
              fontSize: 20.spMin,
              fontWeight: FontWeight.w800,
              color: context.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          8.hSizedBox,
          Text(
            'Your account is scheduled for permanent deletion in 30 days. '
            'Until then ALRT keeps working normally, and you can cancel '
            'any time.',
            style: TextStyle(
              fontSize: 14.spMin,
              color: context.onSurfaceMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNowSection() {
    return _buildSectionCard(
      label: 'What happens now',
      rows: [
        _buildConsequenceRow(
          icon: LucideIcons.eyeOff,
          title: 'Hidden from the community',
          description:
              'Your ALRT reports stop showing in the public feed. Anyone '
              "you've already shared a report or a location with directly "
              'keeps that link.',
          accent: ProfileColors.notifications,
        ),
        _buildDivider(),
        _buildConsequenceRow(
          icon: LucideIcons.bellOff,
          title: 'Notifications stop',
          description:
              "You'll stop receiving alerts, Family, and check-in "
              'notifications.',
          accent: ProfileColors.notifications,
        ),
        _buildDivider(),
        _buildConsequenceRow(
          icon: LucideIcons.shieldCheck,
          title: 'Everything else keeps working',
          description:
              'Signing in, Family, check-ins and reporting all work '
              'normally until day 30 — deletion only takes effect then.',
          accent: ProfileColors.familyAndCheckIns,
        ),
      ],
    );
  }

  Widget _buildRecoverySection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: ProfileColors.familyAndCheckIns.end.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(
          color: ProfileColors.familyAndCheckIns.end.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileGradientIcon(
            icon: LucideIcons.rotateCcw,
            accent: ProfileColors.familyAndCheckIns,
            gradient: true,
          ),
          12.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Changed your mind? You have 30 days',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                    color: context.onSurface,
                  ),
                ),
                4.hSizedBox,
                Text(
                  'Sign in any time before day 30 and choose to recover '
                  "your account — signing in alone doesn't cancel the "
                  'deletion, you\'ll be asked to confirm.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: context.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfter30DaysSection() {
    return _buildSectionCard(
      label: 'After 30 days — permanent',
      rows: [
        _buildConsequenceRow(
          icon: LucideIcons.trash2,
          title: 'Permanent deletion',
          description:
              'Your account and profile data are permanently deleted and '
              'cannot be recovered after this point.',
          accent: const ProfileRowAccent(
            ProfileColors.dangerAction,
            ProfileColors.dangerAction,
          ),
          titleColor: ProfileColors.dangerAction,
        ),
        _buildDivider(),
        _buildConsequenceRow(
          icon: LucideIcons.flagOff,
          title: 'Reports stay, no longer yours',
          description:
              "Hazard reports you've submitted remain visible to the "
              "community, but are no longer linked to your name.",
          accent: const ProfileRowAccent(
            ProfileColors.dangerAction,
            ProfileColors.dangerAction,
          ),
        ),
        _buildDivider(),
        _buildConsequenceRow(
          icon: LucideIcons.star,
          title: 'Progress lost',
          description:
              'Your XP score, achievements, and reliability score are '
              'gone for good.',
          accent: const ProfileRowAccent(
            ProfileColors.dangerAction,
            ProfileColors.dangerAction,
          ),
        ),
      ],
    );
  }

  /// A grouped-card section, matching the Profile screen's own shape: an
  /// uppercase heading over one card holding [rows].
  Widget _buildSectionCard({
    required final String label,
    required final List<Widget> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.spMin,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: context.onSurface,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceCard,
            borderRadius: BorderRadius.circular(20.spMin),
            boxShadow: [
              BoxShadow(color: context.cardShadow, blurRadius: 2.0),
            ],
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 68.spMin, color: context.outline);
  }

  /// One consequence row: colour lives on the icon only, matching the
  /// Profile screen's own restrained treatment — never a filled row
  /// background, even for the danger-accent rows.
  Widget _buildConsequenceRow({
    required final IconData icon,
    required final String title,
    required final String description,
    required final ProfileRowAccent accent,
    final Color? titleColor,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileGradientIcon(icon: icon, accent: accent),
          16.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? context.onSurface,
                  ),
                ),
                4.hSizedBox,
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: context.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Consumer(
      builder: (context, ref, child) {
        final userName = ref.watch(
          providerOfLoggedInUser.select((value) => value?.name ?? 'DELETE'),
        );
        final confirmationText = userName.split(' ').first.toUpperCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileGradientIcon(
                  icon: LucideIcons.userCheck,
                  accent: const ProfileRowAccent(
                    ProfileColors.dangerAction,
                    ProfileColors.dangerAction,
                  ),
                  size: 20,
                ),
                8.spMin.wSizedBox,
                Text(
                  'Confirm your decision',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
              ],
            ),
            12.hSizedBox,
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(16.spMin),
                boxShadow: [
                  BoxShadow(color: context.cardShadow, blurRadius: 2.0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: context.onSurface,
                        height: 1.5,
                        fontFamily: AppTheme.defaultFontFamily,
                      ),
                      children: [
                        const TextSpan(text: 'To confirm deletion, type '),
                        TextSpan(
                          text: '"$confirmationText"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ProfileColors.dangerAction,
                          ),
                        ),
                        const TextSpan(text: ' in the field below:'),
                      ],
                    ),
                  ),
                  12.hSizedBox,
                  TextFormField(
                    controller: _confirmationController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      color: context.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.spMin,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type $confirmationText to confirm',
                      hintStyle: TextStyle(
                        color: context.onSurfaceMuted,
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: context.theme.scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.all(16.spMin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.spMin),
                        borderSide: BorderSide(color: context.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.spMin),
                        borderSide: BorderSide(color: context.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.spMin),
                        borderSide: BorderSide(
                          color: ProfileColors.dangerAction,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _hasConfirmed = value.toUpperCase() == confirmationText;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfProfile.select(
            (value) => value.deleteAccountState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ),
          ),
        );

        return Button.filled(
          value: 'Delete Account',
          color: ProfileColors.dangerAction,
          icon: const Icon(LucideIcons.trash2),
          isLoading: isLoading,
          onPressed: _hasConfirmed ? _handleDeleteAccount : null,
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return Button.bordered(
      value: 'Cancel',
      icon: const Icon(LucideIcons.arrowLeft),
      onPressed: () => context.pop(),
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
              message: 'Deletion scheduled. Your account and data will be permanently removed in 30 days.',
            );
            context.go(AppWrapper.route);
          },
          error: (_) => context.showErrorToast(
            message: 'Failed to delete account. Please try again.',
          ),
          orElse: () {},
        );
      },
    );
  }

  /// Handles the account deletion process.
  void _handleDeleteAccount() {
    context.unfocusInputs();
    ref.read(providerOfProfile.notifier).deleteAccount();
  }
}
