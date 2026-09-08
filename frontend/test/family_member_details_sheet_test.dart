import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_details_sheet.dart';

// Member actions are visible and permission-checked: the sheet shows exactly
// the actions the hub hands it, and a tap closes the sheet then runs it.
void main() {
  const tom = FamilyMember(
    id: 'tom',
    userId: 'u-tom',
    name: 'Tom Nixon',
    sharingLevel: FamilySharingLevel.approximate,
  );

  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext hostContext;
    await tester.binding.setSurfaceSize(const Size(375, 812));
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hostContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    return hostContext;
  }

  testWidgets('host sees ask, request and remove; tapping runs after closing',
      (tester) async {
    final context = await pumpHost(tester);
    var asked = false;
    var removed = false;
    final sheet = showFamilyMemberDetailsSheet(
      context,
      member: tom,
      isMe: false,
      isNearAlert: false,
      hasAnswered: false,
      askedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      onAskToCheckIn: () => asked = true,
      onRequestLocation: () {},
      onRemove: () => removed = true,
    );
    await tester.pumpAndSettle();

    expect(find.text('Tom Nixon'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.textContaining('Asked 2 minutes ago'), findsOneWidget);
    expect(find.text('Sharing level: Approximate'), findsOneWidget);
    expect(find.text('Ask Tom Nixon to check in'), findsOneWidget);
    expect(find.text('Request a one-time location'), findsOneWidget);
    expect(find.text('Remove from circle'), findsOneWidget);
    expect(find.byType(FamilyMemberAvatar), findsOneWidget);

    await tester.tap(find.text('Ask Tom Nixon to check in'));
    await tester.pumpAndSettle();
    await sheet;
    expect(asked, isTrue);
    expect(removed, isFalse);
    expect(find.text('Remove from circle'), findsNothing);
  });

  testWidgets('a non-host never sees Remove; a guest never sees Request',
      (tester) async {
    final context = await pumpHost(tester);
    showFamilyMemberDetailsSheet(
      context,
      member: tom,
      isMe: false,
      isNearAlert: false,
      hasAnswered: true,
      onAskToCheckIn: null,
      onRequestLocation: null,
      onRemove: null,
    );
    await tester.pumpAndSettle();
    expect(find.text('Safe'), findsOneWidget);
    expect(find.text('Remove from circle'), findsNothing);
    expect(find.text('Request a one-time location'), findsNothing);
    expect(find.text('Nothing to do here right now.'), findsOneWidget);
  });

  testWidgets('my own row offers my sharing level, nothing on myself',
      (tester) async {
    final context = await pumpHost(tester);
    showFamilyMemberDetailsSheet(
      context,
      member: tom,
      isMe: true,
      isNearAlert: false,
      hasAnswered: true,
      onChangeMySharing: () {},
    );
    await tester.pumpAndSettle();
    expect(find.text('Tom Nixon (You)'), findsOneWidget);
    expect(find.text('Change my sharing level'), findsOneWidget);
    expect(find.text('Ask Tom Nixon to check in'), findsNothing);
    expect(find.text('Remove from circle'), findsNothing);
  });
}
