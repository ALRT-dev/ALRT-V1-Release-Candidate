import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/providers/service_providers.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/profile/providers/cancel_account_deletion_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_wrapper.dart';

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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.spMin),
          child: Column(
            children: [
              40.hSizedBox,
              _buildHeader(),
              32.hSizedBox,
              _buildDeletionInfoCard(),
              24.hSizedBox,
              _buildWhatHappensSection(),
              32.hSizedBox,
              _buildRecoverButton(),
              16.hSizedBox,
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100.spMin,
          height: 100.spMin,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.schedule_rounded,
            color: AppColors.orange,
            size: 50.spMin,
          ),
        ),
        24.hSizedBox,
        Text(
          'Account Scheduled for Deletion',
          style: TextStyle(
            fontSize: 24.spMin,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        12.hSizedBox,
        Text(
          'Your account is currently inactive and will be permanently deleted soon.',
          style: TextStyle(
            fontSize: 15.spMin,
            color: AppColors.grey,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeletionInfoCard() {
    return Consumer(
      builder: (context, ref, child) {
        final scheduledDeletionAt = ref.watch(
          providerOfLoggedInUser.select((value) => value?.scheduledDeletionAt),
        );

        final daysRemaining = scheduledDeletionAt != null
            ? scheduledDeletionAt.difference(DateTime.now()).inDays
            : 0;

        final formattedDate = scheduledDeletionAt != null
            ? '${_getMonthName(scheduledDeletionAt.month)} ${scheduledDeletionAt.day}, ${scheduledDeletionAt.year}'
            : 'Unknown';

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.spMin),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.red.withValues(alpha: 0.1),
                AppColors.orange.withValues(alpha: 0.05),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppColors.red,
                    size: 28.spMin,
                  ),
                  12.wSizedBox,
                  Text(
                    daysRemaining > 0
                        ? '$daysRemaining days remaining'
                        : 'Deletion imminent',
                    style: TextStyle(
                      fontSize: 20.spMin,
                      fontWeight: FontWeight.bold,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
              12.hSizedBox,
              Text(
                'Permanent deletion on $formattedDate',
                style: TextStyle(
                  fontSize: 14.spMin,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWhatHappensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20.spMin,
              color: AppColors.grey,
            ),
            8.spMin.wSizedBox,
            Text(
              'Current Status',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        16.hSizedBox,
        _buildStatusItem(
          icon: Icons.visibility_off_outlined,
          title: 'Content Hidden',
          description: 'Your ALRTs and content are not visible to other users.',
          color: AppColors.orange,
        ),
        12.hSizedBox,
        _buildStatusItem(
          icon: Icons.notifications_off_outlined,
          title: 'Notifications Paused',
          description: 'You are not receiving any notifications or alerts.',
          color: AppColors.blue,
        ),
        12.hSizedBox,
        _buildStatusItem(
          icon: Icons.restore_rounded,
          title: 'Recoverable',
          description:
              'You can recover your account and all data by clicking the button below.',
          color: AppColors.green,
        ),
      ],
    );
  }

  Widget _buildStatusItem({
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

  Widget _buildRecoverButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfCancelAccountDeletion.select(
            (value) => value.cancelState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ),
          ),
        );

        return Button.filled(
          value: 'Recover My Account',
          color: AppColors.green,
          icon: Icon(Icons.restore_rounded),
          isLoading: isLoading,
          onPressed: _handleRecoverAccount,
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Button.bordered(
      value: 'Logout',
      icon: Icon(Icons.logout_rounded),
      onPressed: _handleLogout,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Listens to changes in the cancel deletion state.
  void _listenToCancelDeletionState() {
    ref.listen<CancelAccountDeletionState>(
      providerOfCancelAccountDeletion.select((value) => value.cancelState),
      (previous, next) {
        next.maybeWhen(
          success: () {
            context.showSuccessToast(
              message: 'Your account has been recovered successfully!',
            );
            context.go(HomeScreen.route);
          },
          error: (error) {
            context.showErrorToast(
              message: 'Failed to recover account. Please try again.',
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
        message: 'Failed to logout. Please try again.',
      ),
    );
  }
}
