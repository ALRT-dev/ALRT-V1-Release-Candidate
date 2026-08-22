import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/providers/states/profile_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:hazard_app/others/app_wrapper.dart';

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
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: AppColors.black,
          ),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        foregroundColor: AppColors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningHeader(),
            24.hSizedBox,
            _buildConsequencesSection(),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.red.withValues(alpha: 0.1),
            AppColors.red500.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(
          color: AppColors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72.spMin,
            height: 72.spMin,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.red,
              size: 40.spMin,
            ),
          ),
          16.hSizedBox,
          Text(
            'Delete Your Account?',
            style: TextStyle(
              fontSize: 22.spMin,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
            textAlign: TextAlign.center,
          ),
          8.hSizedBox,
          Text(
            'Your account will become inactive immediately and will be permanently deleted after 30 days.',
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsequencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Immediate effects section
        _buildSectionHeader(
          icon: Icons.flash_on_outlined,
          title: 'What happens immediately',
        ),
        16.hSizedBox,
        _buildConsequenceItem(
          icon: Icons.visibility_off_outlined,
          title: 'Content Hidden',
          description:
              'All your Alrts and content will be hidden from public view immediately.',
          color: AppColors.orange,
        ),
        12.hSizedBox,
        _buildConsequenceItem(
          icon: Icons.person_off_outlined,
          title: 'Account Inactive',
          description:
              'Your account will be marked as inactive and you will be logged out.',
          color: AppColors.grey,
        ),
        12.hSizedBox,
        _buildConsequenceItem(
          icon: Icons.notifications_off_outlined,
          title: 'Notifications Stopped',
          description: 'You will stop receiving all notifications and alerts.',
          color: AppColors.blue,
        ),
        24.hSizedBox,
        // Recovery info
        _buildRecoveryInfoCard(),
        24.hSizedBox,
        // After 30 days section
        _buildSectionHeader(
          icon: Icons.warning_amber_outlined,
          title: 'After 30 days (permanent)',
        ),
        16.hSizedBox,
        _buildConsequenceItem(
          icon: Icons.delete_forever_outlined,
          title: 'Permanent Deletion',
          description:
              'Your account and all associated data will be permanently deleted and cannot be recovered.',
          color: AppColors.red,
        ),
        12.hSizedBox,
        _buildConsequenceItem(
          icon: Icons.report_off_outlined,
          title: 'Alrts Removed',
          description:
              'All hazard reports you\'ve submitted will be permanently removed from the system.',
          color: AppColors.red,
        ),
        12.hSizedBox,
        _buildConsequenceItem(
          icon: Icons.star_outline,
          title: 'Progress Lost',
          description:
              'Your XP score, achievements, and reliability score will be lost forever.',
          color: AppColors.red,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.spMin,
          color: AppColors.grey,
        ),
        8.spMin.wSizedBox,
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.spMin),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.spMin,
            height: 44.spMin,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Icon(
              Icons.restore_rounded,
              color: AppColors.green,
              size: 24.spMin,
            ),
          ),
          12.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recover Within 30 Days',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen,
                  ),
                ),
                4.hSizedBox,
                Text(
                  'Changed your mind? Simply log back in within 30 days to reactivate your account. All your data and content will be restored.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: AppColors.grey,
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

  Widget _buildConsequenceItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.spMin),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.spMin,
            height: 40.spMin,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22.spMin,
            ),
          ),
          12.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                4.hSizedBox,
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: AppColors.grey,
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
                Icon(
                  Icons.verified_user_outlined,
                  size: 20.spMin,
                  color: AppColors.grey,
                ),
                8.spMin.wSizedBox,
                Text(
                  'Confirm Your Decision',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            12.hSizedBox,
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: AppColors.extraLightGrey,
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: AppColors.black,
                        height: 1.5,
                        fontFamily: AppTheme.defaultFontFamily,
                      ),
                      children: [
                        TextSpan(text: 'To confirm deletion, type '),
                        TextSpan(
                          text: '"$confirmationText"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.red,
                          ),
                        ),
                        TextSpan(text: ' in the field below:'),
                      ],
                    ),
                  ),
                  12.hSizedBox,
                  TextFormField(
                    controller: _confirmationController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.spMin,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type $confirmationText to confirm',
                      hintStyle: TextStyle(
                        color: AppColors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: EdgeInsets.all(16.spMin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.spMin),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.spMin),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.spMin),
                        borderSide: BorderSide(color: AppColors.red, width: 2),
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
          color: AppColors.red,
          icon: Icon(Icons.delete_forever_rounded),
          isLoading: isLoading,
          onPressed: _hasConfirmed ? _handleDeleteAccount : null,
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return Button.bordered(
      value: 'Cancel',
      icon: Icon(Icons.arrow_back_rounded),
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
