import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';

// People are circles (approved design); only places stay rounded squares.
void main() {
  testWidgets('member avatar is circular with initials', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(
            body: FamilyMemberAvatar(
              member: FamilyMember(id: 'a', userId: 'u', name: 'Amy Bell'),
              showStatusDot: false,
            ),
          ),
        ),
      ),
    );
    expect(find.text('AB'), findsOneWidget);
    final container = tester.widget<Container>(
      find.ancestor(of: find.text('AB'), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.borderRadius, isNull);
  });
}
