import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';

/// Shown once, right after an ALRT+ purchase: celebrate briefly, show the
/// open seats, and push the single highest-value action — inviting family.
class AlrtPlusWelcomeScreen extends ConsumerWidget {
  const AlrtPlusWelcomeScreen({super.key});

  static const route = '/alrt-plus/welcome';

  static const _totalSeats = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AlrtPlusStyle.body,
      body: Column(
        children: [
          _bandBuilder(context),
          Expanded(
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                padding: EdgeInsets.fromLTRB(18.spMin, 16.spMin, 18.spMin, 18.spMin),
                child: Column(
                  children: [
                    _haloBuilder(),
                    SizedBox(height: 16.spMin),
                    Text(
                      'Welcome to ALRT +',
                      style: TextStyle(
                        fontSize: 23.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AlrtPlusStyle.ink,
                      ),
                    ),
                    SizedBox(height: 7.spMin),
                    Text(
                      'Your free month has started. The family layer is on, '
                      'and there are ${_totalSeats - 1} seats waiting for your people.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.spMin,
                        height: 1.6,
                        color: AlrtPlusStyle.inkSoft,
                      ),
                    ),
                    SizedBox(height: 18.spMin),
                    _seatRowBuilder(),
                    SizedBox(height: 18.spMin),
                    const AlrtPlusLavNote(
                      lead: 'No surprises.',
                      text: 'We remind you a week before your free month ends, '
                          'and you can cancel anytime in your app store.',
                    ),
                    const Spacer(),
                    AlrtPlusCta(
                      label: 'Invite your family',
                      onPressed: () {
                        ref
                            .read(providerOfPendingFamilyInvite.notifier)
                            .set(true);
                        context.pop(true);
                      },
                    ),
                    SizedBox(height: 11.spMin),
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: Text(
                        "I'll do this later",
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bandBuilder(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AlrtPlusStyle.bandGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 12.spMin,
        left: 22.spMin,
        right: 22.spMin,
        bottom: 22.spMin,
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: AlrtPlusPill(onDark: true),
      ),
    );
  }

  Widget _haloBuilder() {
    return Container(
      width: 84.spMin,
      height: 84.spMin,
      margin: EdgeInsets.only(top: 18.spMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.spMin),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF4EC), Color(0xFFFFE9DA)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF500A).withValues(alpha: 0.24),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.spMin),
        child: Image.asset('assets/logos/alrt_logo.png', fit: BoxFit.contain),
      ),
    );
  }

  Widget _seatRowBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSeats, (index) {
        final isYou = index == 0;
        return Container(
          width: 15.spMin,
          height: 15.spMin,
          margin: EdgeInsets.symmetric(horizontal: 3.spMin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isYou ? AlrtPlusStyle.ctaGradient : null,
            border: isYou
                ? null
                : Border.all(color: AlrtPlusStyle.seatOpenBorder, width: 1.6),
          ),
        );
      }),
    );
  }
}
