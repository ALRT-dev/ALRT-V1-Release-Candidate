import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/learn/providers/guide_for_category_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/others/app_colors.dart';

void main() {
  group('level pill ink (owner review, 13 November 2026)', () {
    test('dark text on the light levels, white on emergency red', () {
      const dark = Color(0xFF17171C);
      expect(AlertCardStyle.inkOn(AppColors.advice), dark);
      expect(AlertCardStyle.inkOn(AppColors.watchAndAct), dark);
      expect(AlertCardStyle.inkOn(AppColors.info), dark);
      expect(AlertCardStyle.inkOn(AppColors.emergency), Colors.white);
      expect(
        AlertCardStyle.inkOn(AlertCardStyle.labelInkNeutral),
        Colors.white,
      );
    });
  });

  group('guide key', () {
    test('plain category id without a level', () {
      expect(guideForCategoryKey('bushfire'), 'bushfire');
      expect(guideForCategoryKey('bushfire', '  '), 'bushfire');
    });

    test('category and level when the alert has one', () {
      expect(
        guideForCategoryKey('bushfire', 'Watch and Act'),
        'bushfire|Watch and Act',
      );
    });
  });
}
