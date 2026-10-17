import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The accounts this person has blocked, and the way back.
///
/// A block with no way to undo it is a trap rather than a tool, so this
/// screen exists purely to reverse one. Nothing here identifies anyone
/// beyond the display name needed to tell one block from another.
///
/// Prototype "BlockedAccounts" board: white header with back arrow, title
/// and subtitle, then one white group of rows (name, "Unblock") or a card
/// saying "You have not blocked anyone."
class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  static const route = '/blocked-accounts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(providerOfBlockedUsers);

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(
            title: 'Blocked accounts',
            subtitle: 'People whose reports you have hidden',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 32.spMin),
              children: [
                blocked.when(
                  loading: () => Padding(
                    padding: EdgeInsets.only(top: 32.spMin),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => ProfileCard(
                    children: [
                      const ProfileMutedText(
                        'Your blocked list could not be loaded.',
                      ),
                      ProfileButton(
                        label: 'Try again',
                        kind: ProfileButtonKind.secondary,
                        onPressed: () => ref.invalidate(providerOfBlockedUsers),
                      ),
                    ],
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return const ProfileCard(
                        children: [
                          ProfileMutedText('You have not blocked anyone.'),
                        ],
                      );
                    }
                    return ProfileRowGroup(
                      rows: [
                        for (final user in users)
                          ProfileListRow(
                            key: ValueKey(user.userId),
                            title: user.name,
                            trailing: _UnblockButton(
                              onPressed: () => ref
                                  .read(providerOfBlockedUsers.notifier)
                                  .unblock(user.userId),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The prototype's small outlined button (`small`): 36 px, radius 10.
class _UnblockButton extends StatelessWidget {
  const _UnblockButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 36.spMin,
        padding: EdgeInsets.symmetric(horizontal: 14.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.spMin),
          border: Border.all(color: ProfilePageKit.hairline),
        ),
        child: Text(
          'Unblock',
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
