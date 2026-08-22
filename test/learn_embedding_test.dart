import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Learn tab was blank on the alerts feed for a layout reason, not a
/// data one: it returned a ListView, and the feed embeds it in a
/// SliverToBoxAdapter, which hands its child UNBOUNDED height. A scrollable
/// given unbounded height throws, and in a release build that exception
/// renders as empty space rather than an error, so the tab just looked
/// like it had nothing in it.
///
/// These pin the shape of the fix rather than the Learn screen itself,
/// which needs a live provider: a self-scrolling child inside a
/// SliverToBoxAdapter throws, and a plain-column child does not.
void main() {
  Widget host(final Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [SliverToBoxAdapter(child: child)],
        ),
      ),
    );
  }

  testWidgets('a ListView inside a SliverToBoxAdapter throws', (tester) async {
    // The failed layout cascades, so collect every error rather than
    // reading only the first one the harness hands back.
    final logged = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) => logged.add(details.toString());

    await tester.pumpWidget(
      host(ListView(children: const [Text('anything')])),
    );

    FlutterError.onError = previous;
    // Drain, so the failure does not leak into the next test.
    while (tester.takeException() != null) {}

    expect(
      logged.any((e) => e.contains('unbounded height')),
      isTrue,
      reason: 'this is the exception that rendered as a blank Learn tab',
    );
  });

  testWidgets('a column child lays out and is visible', (tester) async {
    await tester.pumpWidget(
      host(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [Text('BE READY FOR')]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('BE READY FOR'), findsOneWidget);
  });

  testWidgets('a Center child also needs bounding', (tester) async {
    // The loading and error states were Center widgets, which hit the same
    // unbounded-height problem once they are the returned child.
    await tester.pumpWidget(
      host(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: Text('Could not load guides')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Could not load guides'), findsOneWidget);
  });
}
