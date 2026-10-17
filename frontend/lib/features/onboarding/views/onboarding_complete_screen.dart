import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Set up complete (board SetUpComplete): a green tick, "Set up
/// complete", the first points, one next step, and "Start using ALRT".
class OnboardingCompleteScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteScreen({super.key});

  static const route = '/onboarding/complete';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState
    extends ConsumerState<OnboardingCompleteScreen>
    with SingleTickerProviderStateMixin {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _green = Color(0xFF16A34A);
  static const _greenTint = Color(0xFFE6F6EC);
  static const _label = Color(0xFFB84500);
  static const _orange = Color(0xFFE8622A);

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  )..forward();

  late final Animation<double> _tickScale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.spMin, 64.spMin, 24.spMin, 24.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ScaleTransition(
                  scale: _tickScale,
                  child: Container(
                    width: 72.spMin,
                    height: 72.spMin,
                    decoration: const BoxDecoration(
                      color: _greenTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.check, size: 36.spMin, color: _green),
                  ),
                ),
              ),
              SizedBox(height: 14.spMin),
              Text(
                'Set up complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: _ink,
                ),
              ),
              SizedBox(height: 14.spMin),
              Text(
                'Your first 20 points are on the board.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.spMin, height: 1.45, color: _muted),
              ),
              SizedBox(height: 14.spMin),
              Container(
                padding: EdgeInsets.all(16.spMin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ONE NEXT STEP',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: _label,
                      ),
                    ),
                    SizedBox(height: 10.spMin),
                    Text(
                      'Save the place that matters most',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 10.spMin),
                    Text(
                      'Alerts for it reach you first, even when you are away.',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        height: 1.45,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.spMin),
              Container(
                height: 54.spMin,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(14.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.spMin),
                    onTap: _gotoMapScreen,
                    child: Center(
                      child: Text(
                        'Start using ALRT',
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w700,
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
      ),
    );
  }

  void _gotoMapScreen() {
    context.go(
      AppWrapper.route,
      extra: AppWrapperArgs(
        homeScreenArgs: HomeScreenArgs(
          initialTab: HomeTab.map,
        ),
      ),
    );
  }
}
