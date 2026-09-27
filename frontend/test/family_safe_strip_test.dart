import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/views/widgets/family_safe_strip.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';

/// The alert check-in strip (issue 5) on every alert kind: it always
/// paints something truthful, it never sends anything on its own, and it
/// names the circle it would go to.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget app(FamilyProviderState state, Hazard hazard) => ProviderScope(
    overrides: [
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(ref: ref, state: state, bootstrap: false),
      ),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: FamilySafeStrip(hazard: hazard)),
        ),
      ),
    ),
  );

  final kinds = <String, Hazard>{
    'AWS Emergency Warning': const Hazard(
      id: 'h1',
      title: 'Bushfire',
      isAwsCompliant: true,
    ),
    'Official non-AWS': const Hazard(
      id: 'h2',
      title: 'Road closed',
      isAwsCompliant: false,
      source: HazardSource(id: 'qldTraffic'),
    ),
    'Global humanitarian': const Hazard(
      id: 'h3',
      title: 'Flood',
      source: HazardSource(id: 'gdacsGlobal'),
    ),
    'Community report': const Hazard(
      id: 'h4',
      title: 'Tree down',
      reportedBy: AppUser(id: 'u9'),
    ),
    'ALRT Intel': const Hazard(
      id: 'h5',
      title: 'Storm cell',
      source: HazardSource(id: 'intel', shape: HazardSourceShape.shield),
    ),
  };

  const withCircle = FamilyProviderState(
    hasLoadedOnce: true,
    circle: FamilyCircle(id: 'c1', name: 'Nixons', myMemberId: 'me'),
    circles: [
      FamilyCircleSummary(circleId: 'c1', name: 'Nixons', myMemberId: 'me'),
    ],
  );

  for (final entry in kinds.entries) {
    testWidgets(
      '${entry.key}: the strip offers a check-in to the named circle',
      (tester) async {
        await tester.pumpWidget(app(withCircle, entry.value));
        await tester.pump();
        expect(
          find.text('Near this alert? Let your family know you are okay.'),
          findsOneWidget,
        );
        expect(find.textContaining('To Nixons'), findsOneWidget);
        expect(find.text('Check in'), findsOneWidget);
      },
    );
  }

  testWidgets('with two circles the destination can be changed', (
    tester,
  ) async {
    const two = FamilyProviderState(
      hasLoadedOnce: true,
      circle: FamilyCircle(id: 'c1', name: 'Nixons', myMemberId: 'me'),
      circles: [
        FamilyCircleSummary(circleId: 'c1', name: 'Nixons', myMemberId: 'me'),
        FamilyCircleSummary(
          circleId: 'c2',
          name: 'Weekend crew',
          myMemberId: 'me2',
        ),
      ],
    );
    await tester.pumpWidget(app(two, kinds.values.first));
    await tester.pump();
    expect(find.textContaining('change circle'), findsOneWidget);
  });

  testWidgets('no circle: points at Family, no Check in button', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const FamilyProviderState(hasLoadedOnce: true), kinds.values.first),
    );
    await tester.pump();
    expect(
      find.text('Join or create a family circle to check in from an alert.'),
      findsOneWidget,
    );
    expect(find.text('Check in'), findsNothing);
  });

  testWidgets(
    'before the circle has loaded it says so instead of "no circle"',
    (tester) async {
      await tester.pumpWidget(
        app(const FamilyProviderState(), kinds.values.first),
      );
      await tester.pump();
      expect(find.text('Loading your family circle…'), findsOneWidget);
      expect(find.textContaining('Join or create'), findsNothing);
    },
  );

  testWidgets(
    'opening an alert sends nothing: the check-in state stays initial',
    (tester) async {
      await tester.pumpWidget(app(withCircle, kinds.values.first));
      await tester.pump();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FamilySafeStrip)),
      );
      expect(container.read(providerOfFamily).checkInState.isLoading, isFalse);
      expect(container.read(providerOfFamily).checkInState.isSuccess, isFalse);
    },
  );
}
