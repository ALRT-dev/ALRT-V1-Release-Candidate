import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Shown instead of the plain paywall for someone who was on ALRT+ before
/// but whose subscription has genuinely ended — never for someone who has
/// simply never subscribed (see providerOfExpiredAlrtPlus). Cancelling
/// alone never reaches this screen: RevenueCat keeps the entitlement
/// active until the paid period actually runs out, and only then does the
/// entitlement disappear from `.active`, which is what routes here.
///
/// The message is deliberately calm: nothing safety-related was ever
/// behind ALRT+, so ending a subscription never reads as losing
/// protection — only the Family-hosting and extra-locations perks pause.
class AlrtPlusExpiredScreen extends ConsumerWidget {
  const AlrtPlusExpiredScreen({super.key, this.entitlement});

  static const route = '/alrt-plus/expired';

  /// The lapsed entitlement, so the end date can be shown when known. Null
  /// is handled gracefully — the copy just drops the date.
  final EntitlementInfo? entitlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wasHosting = ref.watch(
      providerOfFamily.select(
        (s) => s.circles.any((c) => c.isOwned),
      ),
    );
    final endedOn = _endedOnBuilder();
    return Scaffold(
      backgroundColor: AlrtPlusStyle.body,
      body: Column(
        children: [
          _bandBuilder(context),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20.spMin,
                  20.spMin,
                  20.spMin,
                  20.spMin,
                ),
                children: [
                  Text(
                    "You're back on the free plan",
                    style: TextStyle(
                      fontSize: 20.spMin,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AlrtPlusStyle.ink,
                    ),
                  ),
                  SizedBox(height: 7.spMin),
                  Text(
                    endedOn != null
                        ? 'Your ALRT + subscription ended on $endedOn. '
                              "ALRT stays free and safe to use - here's what "
                              'that means.'
                        : 'Your ALRT + subscription has ended. ALRT stays '
                              "free and safe to use - here's what that "
                              'means.',
                    style: TextStyle(
                      fontSize: 13.spMin,
                      height: 1.55,
                      color: AlrtPlusStyle.inkSoft,
                    ),
                  ),
                  SizedBox(height: 18.spMin),
                  _freeCardBuilder(),
                  SizedBox(height: 10.spMin),
                  _pausedCardBuilder(wasHosting: wasHosting),
                  SizedBox(height: 18.spMin),
                  AlrtPlusCta(
                    label: 'Resubscribe to ALRT +',
                    onPressed: () => context.push(AlrtPlusPaywallScreen.route),
                  ),
                  SizedBox(height: 10.spMin),
                  TextButton(
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                    child: Text(
                      "I'm fine on the free plan",
                      style: TextStyle(
                        fontSize: 12.5.spMin,
                        fontWeight: FontWeight.w600,
                        color: AlrtPlusStyle.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _endedOnBuilder() {
    final expiration = entitlement?.expirationDate;
    if (expiration == null) return null;
    final date = DateTime.tryParse(expiration);
    if (date == null) return null;
    return DateFormat('d MMM yyyy').format(date.toLocal());
  }

  Widget _bandBuilder(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AlrtPlusStyle.bandGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 4.spMin,
        left: 10.spMin,
        right: 22.spMin,
        bottom: 20.spMin,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/'),
            icon: Icon(
              LucideIcons.arrowLeft,
              color: Colors.white,
              size: 22.spMin,
            ),
          ),
          SizedBox(width: 2.spMin),
          const AlrtPlusPill(onDark: true),
        ],
      ),
    );
  }

  Widget _freeCardBuilder() {
    const items = [
      ('SOS alerts', LucideIcons.siren),
      ('Check-ins with your circle', LucideIcons.messageCircle),
      ('Journey sharing', LucideIcons.mapPinned),
      ('Alerts, map and emergency guidance', LucideIcons.shield),
      ('Joining a Family circle you\'re invited to', LucideIcons.users),
      ('One saved location', LucideIcons.mapPin),
    ];
    return _cardBuilder(
      title: 'Always free, still on',
      titleColor: AlrtPlusStyle.ink,
      children: [
        for (final item in items) _rowBuilder(item.$1, item.$2, on: true),
      ],
    );
  }

  Widget _pausedCardBuilder({required final bool wasHosting}) {
    final items = <(String, IconData)>[
      ('Hosting a Family circle', LucideIcons.crown),
      ('More than one saved location', LucideIcons.mapPin),
      ('30 Ask ALRT questions a day (back to 5)', LucideIcons.sparkles),
    ];
    return _cardBuilder(
      title: 'Paused until you resubscribe',
      titleColor: AlrtPlusStyle.inkSoft,
      children: [
        for (final item in items) _rowBuilder(item.$1, item.$2, on: false),
        if (wasHosting) ...[
          SizedBox(height: 10.spMin),
          AlrtPlusLavNote(
            lead: 'Hosting a circle?',
            text: 'It keeps working as usual for 7 days while it looks '
                'for a new host to take over, so nobody in it loses '
                'access suddenly.',
          ),
        ],
      ],
    );
  }

  Widget _rowBuilder(
    final String label,
    final IconData icon, {
    required final bool on,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.spMin),
      child: Row(
        children: [
          Icon(
            on ? LucideIcons.check : icon,
            size: 16.spMin,
            color: on ? AlrtPlusStyle.greenGradient.colors.last : AlrtPlusStyle.inkFaint,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5.spMin,
                fontWeight: FontWeight.w600,
                color: on ? AlrtPlusStyle.ink : AlrtPlusStyle.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBuilder({
    required final String title,
    required final Color titleColor,
    required final List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.spMin, vertical: 13.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A1560).withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AlrtPlusStyle.label,
            ),
          ),
          SizedBox(height: 4.spMin),
          ...children,
        ],
      ),
    );
  }
}
