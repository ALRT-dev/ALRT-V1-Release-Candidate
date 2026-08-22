import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  /// Displays a loading spinner.
  const Spinner({
    super.key,
    this.color,
    this.strokeWidth = 1.2,
    this.size = 40.0,
  });

  /// The color of the spinner.
  final Color? color;

  /// The stroke width of the spinner.
  final double strokeWidth;

  /// The size of the spinner.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: strokeWidth,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}
