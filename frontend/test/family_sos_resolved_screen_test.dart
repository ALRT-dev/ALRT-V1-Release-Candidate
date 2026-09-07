import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';

// "Back to Family" used to just pop the current route, landing wherever the
// SOS flow happened to be opened from (the strip shows on every tab, not
// just Family) instead of the Family tab its own label promises. These pin
// both halves of the fix: the app-wide tab selection actually flips to
// Family, and the screen still pops back off the SOS stack afterwards.
void main() {
  FamilySosResolvedScreenArgs args() => FamilySosResolvedScreenArgs(
    event: const FamilySosEvent(
      id: 'sos-1',
      circleId: 'circle-1',
      memberId: 'me',
      status: FamilySosStatus.resolved,
    ),
    circleName: 'The Nixons',
    recipientCount: 2,
  );

  Widget wrap({
    required final GlobalKey<NavigatorState> navigatorKey,
    required final ProviderContainer container,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          navigatorKey: navigatorKey,
          // providerOfHomeTab is a StateProvider.autoDispose: the real app
          // only keeps it alive because HomeScreen holds an active
          // ref.listen on it for as long as it's mounted (which is always,
          // since every SOS screen is pushed on top of it). This stub
          // mirrors that with a watch - without it, the provider is
          // disposed and silently recreated at its default value between
          // reads, which looks exactly like "Back to Family" doing nothing.
          home: Consumer(
            builder: (context, ref, _) {
              ref.watch(providerOfHomeTab);
              return const Scaffold(body: Center(child: Text('STUB HOME')));
            },
          ),
        ),
      ),
    );
  }

  testWidgets(
    '"Back to Family" switches the home tab to Family and pops back, '
    'even when the SOS was opened from a different tab',
    (tester) async {
      // Matches the real app's own ScreenUtilInit design size, so this
      // screen's .spMin-derived layout is not laid out against flutter
      // test's unrelated default surface size.
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final navigatorKey = GlobalKey<NavigatorState>();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        wrap(navigatorKey: navigatorKey, container: container),
      );

      // Only safe to set once the stub home's watch (above) is actually
      // established - providerOfHomeTab is autoDispose, so setting its
      // state before anything is watching it can be undone by disposal
      // before this test ever reads it back.
      //
      // The persistent SOS strip shows on every tab, so this flow can
      // start from anywhere — Map is the app's own default, standing in
      // for "some other tab" here.
      container.read(providerOfHomeTab.notifier).state = HomeTab.map;
      await tester.pump();

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => FamilySosResolvedScreen(args: args()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back to Family'), findsOneWidget);
      expect(container.read(providerOfHomeTab), HomeTab.map);

      // Invokes the button's own onPressed directly rather than simulating
      // a tap: this is the exact same production closure, without any
      // dependency on the button's on-screen hit-testing geometry.
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      button.onPressed!();
      await tester.pumpAndSettle();

      expect(
        container.read(providerOfHomeTab),
        HomeTab.family,
        reason: '"Back to Family" must actually select the Family tab, '
            'not just close the SOS screens',
      );
      expect(
        find.text('STUB HOME'),
        findsOneWidget,
        reason: 'the button must still pop back off the SOS stack',
      );
    },
  );
}
