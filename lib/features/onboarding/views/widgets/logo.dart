import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logos/alrt_logo_detailed.png',
      width: 120,
      filterQuality: FilterQuality.high,
    );
  }
}
