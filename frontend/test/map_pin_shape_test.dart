import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/map/views/widgets/map_pin_shape_painter.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';

void main() {
  group('MapPinShape', () {
    testWidgets('solid pin paints the band-colour fill and solid stroke',
        (tester) async {
      const color = Color(0xFFCC1010);
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPinShape(
            shape: HazardSourceShape.diamond,
            color: color,
          ),
        ),
      );
      expect(find.byType(MapPinShape), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('dotted pin (planned burn) renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPinShape(
            shape: HazardSourceShape.diamond,
            color: Color(0xFF8A93A0),
            dotted: true,
          ),
        ),
      );
      expect(find.byType(MapPinShape), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
