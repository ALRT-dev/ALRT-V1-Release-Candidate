import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The start-up screen. Settled ruling (product owner, Splash board): the
/// front page is white with the logo only. No background, no coloured
/// rings or dots, no glow behind the logo.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const route = '/splash';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Hero(
          tag: 'app_logo',
          child: Image.asset(
            'assets/logos/alrt_logo_detailed.png',
            width: 280.spMin,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
