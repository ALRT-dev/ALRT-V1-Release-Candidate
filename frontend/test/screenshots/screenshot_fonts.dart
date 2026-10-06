// Loads the fonts the screenshot harnesses draw with, so text renders as
// glyphs rather than boxes in goldens.
import 'dart:io';

import 'package:flutter/services.dart';

Future<void> loadScreenshotFonts() async {
  // FLUTTER_ROOT is set by `flutter test`; the Dart VM path is inside
  // bin/cache/dart-sdk, so walk up to the SDK root as a fallback.
  final sdk =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final materialFonts = '$sdk/bin/cache/artifacts/material_fonts';
  // ignore: avoid_print
  print(
    'fonts from $materialFonts exists=${Directory(materialFonts).existsSync()}',
  );
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File(f);
      if (!file.existsSync()) continue;
      loader.addFont(
        file.readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
    }
    await loader.load();
  }

  // The theme asks for Arial; on a phone that resolves to the system sans.
  await load('Arial', [
    '$materialFonts/Roboto-Regular.ttf',
    '$materialFonts/Roboto-Medium.ttf',
    '$materialFonts/Roboto-Bold.ttf',
    '$materialFonts/Roboto-Black.ttf',
  ]);
  await load('Roboto', [
    '$materialFonts/Roboto-Regular.ttf',
    '$materialFonts/Roboto-Medium.ttf',
    '$materialFonts/Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['$materialFonts/MaterialIcons-Regular.otf']);
  final pub =
      Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  final lucideDir =
      Directory('$pub/hosted/pub.dev')
          .listSync()
          .whereType<Directory>()
          .where((d) => d.path.contains('/lucide_icons_flutter-'))
          .map((d) => d.path)
          .toList()
        ..sort();
  if (lucideDir.isNotEmpty) {
    await load('packages/lucide_icons_flutter/Lucide', [
      '${lucideDir.last}/assets/build_font/LucideVariable-w500.ttf',
    ]);
  }
}
