import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The accounts this person has blocked, and the way back.
///
/// A block with no way to undo it is a trap rather than a tool, so this
/// screen exists purely to reverse one. Nothing here identifies anyone
/// beyond the display name needed to tell one block from another.
class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  static const route = '/blocked-accounts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(providerOfBlockedUsers);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8C00), Color(0xFFFF6B01)],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        ),
        title: Text(
          'Blocked accounts',
          style: TextStyle(
            fontSize: 17.spMin,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: blocked.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _messageBuilder(
          'Your blocked list could not be loaded. Pull down to retry.',
        ),
        data: (users) {
          if (users.isEmpty) {
            return _messageBuilder(
              'You have not blocked anyone.\n\nBlocking someone hides their '
              'community reports from you. They are never told, and their '
              'reports stay visible to everyone else.',
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.spMin),
            itemCount: users.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.spMin),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 12.spMin,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.userX,
                      size: 18.spMin,
                      color: AppColors.grey,
                    ),
                    SizedBox(width: 11.spMin),
                    Expanded(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(providerOfBlockedUsers.notifier)
                          .unblock(user.userId),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.orange,
                      ),
                      child: Text(
                        'Unblock',
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _messageBuilder(final String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.spMin),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.spMin,
            height: 1.55,
            color: AppColors.grey,
          ),
        ),
      ),
    );
  }
}
