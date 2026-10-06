import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hazard_app/features/subscription/utils/store_management.dart';

/// Calm amber banner on My plans while the store retries a failed renewal
/// of the person's ALRT + Individual. Access continues until the store
/// says it has ended. Renders nothing when billing is fine.
class BillingIssueBanner extends ConsumerWidget {
  const BillingIssueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasIssue = ref.watch(providerOfAlrtPlusBillingIssue).value;
    if (hasIssue != true) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 0),
      padding: EdgeInsets.all(13.spMin),
      decoration: BoxDecoration(
        gradient: AlrtPlusStyle.amberGradient,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: AlrtPlusStyle.goldText.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.spMin,
            height: 30.spMin,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Icon(
              LucideIcons.creditCard,
              size: 16.spMin,
              color: AlrtPlusStyle.goldText,
            ),
          ),
          SizedBox(width: 11.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We couldn't renew ALRT +",
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6E4E10),
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  'ALRT + stays on while the store retries. Update your '
                  'payment method to keep it.',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    height: 1.5,
                    color: const Color(0xFF8A6A24),
                  ),
                ),
                SizedBox(height: 10.spMin),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E4E10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _openStoreManagement(ref, context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.spMin,
                          vertical: 8.spMin,
                        ),
                        child: Text(
                          'Update payment',
                          style: TextStyle(
                            fontSize: 11.5.spMin,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStoreManagement(
    final WidgetRef ref,
    final BuildContext context,
  ) async {
    // RevenueCat's managementURL, else the store's own subscriptions page.
    final opened = await openSubscriptionManagement(
      ref.read(providerOfRevenueCat),
    );
    if (!opened) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Update your payment method in your app store account settings.',
            ),
          ),
        );
      }
    }
  }
}
