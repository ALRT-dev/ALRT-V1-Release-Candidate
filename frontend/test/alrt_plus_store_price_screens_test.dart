import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/shared/providers/live_connection_provider.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_benefits.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show StoreProduct;

import 'support/fake_store_gateway.dart';

/// Build 48: every price a person sees is the store's amount and currency,
/// consistent across the plan cards, the line under the purchase button
/// and the subscription summary. A fake store answers like Google Play
/// does for an Australian account (AUD formatted with a bare "$").
class _LiveOn extends LiveConnectionNotifier {
  @override
  bool build() => true;
}

Future<RevenueCatService> _service({bool entitled = false}) async {
  final service = RevenueCatService(
    gateway: FakeStoreGateway(entitled: entitled),
    apiKeyOverride: 'test-key',
  );
  await service.ensureConfigured('u-test');
  return service;
}

Widget _app(
  Widget home,
  RevenueCatService service, {
  bool plus = false,
  double textScale = 1.0,
}) => ProviderScope(
  overrides: [
    providerOfRevenueCat.overrideWithValue(service),
    providerOfFamily.overrideWith(
      (ref) => FamilyProvider(
        ref: ref,
        bootstrap: false,
        state: const FamilyProviderState(hasLoadedOnce: true),
      ),
    ),
    providerOfLiveConnection.overrideWith(_LiveOn.new),
    providerOfAlrtPlusBillingIssue.overrideWith((ref) async => false),
    providerOfAlrtPlus.overrideWith((ref) async => plus),
    providerOfExpiredAlrtPlus.overrideWith((ref) async => null),
  ],
  child: ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      theme: AppTheme.lightPalette,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    ),
  ),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    // A narrow phone (360 logical px wide, like many Android phones), tall
    // enough that the paywall's list builds every row without scrolling.
    view.physicalSize = const Size(1080, 7500);
    view.devicePixelRatio = 3.0;
  });
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets(
    'paywall cards, currency line and the line under the button all quote the store',
    (tester) async {
      final service = await _service();
      await tester.pumpWidget(_app(const AlrtPlusPaywallScreen(), service));
      await tester.pumpAndSettle();

      // Cards: the store's formatted amount, then "AUD · per <period>".
      expect(find.text(r'$9.99'), findsOneWidget);
      expect(find.text(r'$99.99'), findsOneWidget);
      expect(find.text('AUD · per month'), findsOneWidget);
      expect(find.text('AUD · per year'), findsOneWidget);
      // The annual package is preselected; the line under the button
      // names its price with the currency, not a hard-coded figure.
      expect(find.textContaining(r'$99.99 AUD a year'), findsOneWidget);
      expect(find.textContaining('US\$'), findsNothing);
      expect(find.textContaining('Preview prices'), findsNothing);
      // Condensed by default: the summary, not the five-row table.
      expect(find.text(kAlrtPlusStaysFreeLine), findsOneWidget);
      expect(find.text('Free: Always free'), findsNothing);
      await tester.tap(find.text('Compare Free and ALRT+'));
      await tester.pumpAndSettle();
      expect(find.text('Free: Always free'), findsWidgets);
      await tester.tap(find.text('Hide the comparison'));
      await tester.pumpAndSettle();
      expect(find.text('Free: Always free'), findsNothing);

      await tester.tap(find.text(r'$9.99'));
      await tester.pumpAndSettle();
      expect(find.textContaining(r'$9.99 AUD a month'), findsOneWidget);
      expect(find.textContaining(r'$99.99 AUD a year'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the paywall holds together at large text', (tester) async {
    final service = await _service();
    await tester.pumpWidget(
      _app(const AlrtPlusPaywallScreen(), service, textScale: 1.4),
    );
    await tester.pumpAndSettle();
    expect(find.text('AUD · per month'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'no overflow at 1.4x');
  });

  testWidgets(
    'the manage screen quotes the same store price for the active plan',
    (tester) async {
      final service = await _service(entitled: true);
      await tester.pumpWidget(
        _app(const AlrtPlusManageScreen(), service, plus: true),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining(r'Monthly · $9.99 AUD a month'),
        findsOneWidget,
      );
      expect(find.textContaining('renews 9 Oct 2026'), findsOneWidget);
    },
  );

  testWidgets(
    'the manage screen shows no price when the store cannot say',
    (tester) async {
      final gateway = FakeStoreGateway(entitled: true);
      final service = RevenueCatService(
        gateway: _NoProducts(gateway),
        apiKeyOverride: 'test-key',
      );
      await service.ensureConfigured('u-test');
      await tester.pumpWidget(
        _app(const AlrtPlusManageScreen(), service, plus: true),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Monthly · renews 9 Oct 2026'),
        findsOneWidget,
      );
      expect(find.textContaining('AUD'), findsNothing);
      expect(find.textContaining(r'$9.99'), findsNothing);
    },
  );
}

/// The fake store, but its product lookup fails (offline store).
class _NoProducts extends FakeStoreGateway {
  _NoProducts(FakeStoreGateway base) : super(entitled: base.entitled);
  @override
  Future<List<StoreProduct>> products(List<String> identifiers) =>
      throw StateError('store unreachable');
}
