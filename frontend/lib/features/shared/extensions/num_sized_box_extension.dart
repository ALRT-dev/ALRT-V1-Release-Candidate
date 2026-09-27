import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension NumSizedBoxExt on num {
  /// Returns a [SizedBox] with a width of [this].
  Widget get wSizedBox => SizedBox(width: toDouble().spMin);

  /// Returns a [SizedBox] with a height of [this].
  Widget get hSizedBox => SizedBox(height: toDouble().spMin);
}
