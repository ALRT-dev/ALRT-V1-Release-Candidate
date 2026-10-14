/// Cleans an agency's verbatim text for the alert screen.
///
/// Agencies such as DFES publish ONE block that holds the facts, their own
/// "WHAT TO DO" list, road closures and more. The screen has separate
/// sections for those, so "What we know" must hold the facts only and
/// "What to do" must not be repeated inside it.
abstract final class AlertTextUtil {
  /// Most points either section shows.
  static const int maxPoints = 3;

  /// What to do always carries at least two points (owner, 14 Oct 2026).
  static const int minActions = 2;

  /// A line that starts the agency's own instruction or logistics block.
  /// Everything from here on belongs to another section, so it is cut.
  static final RegExp _sectionHeading = RegExp(
    r'^(what to do|what you should do|actions?( to take)?|recommended actions?|'
    r'road closures?( and conditions)?|if driving|emergency (kit|contacts?)|'
    r'more information|for more information)\s*:?\s*$',
    caseSensitive: false,
  );

  /// Header lines the app already shows elsewhere.
  static final RegExp _metaLine = RegExp(
    r'^(warning type|region|issued|updated|status)\s*:',
    caseSensitive: false,
  );

  static final RegExp _bullet = RegExp(r'^[•·*\-]\s*');

  /// The facts only, as 1 to [maxPoints] short points.
  static List<String> whatWeKnowPoints(final String? description) {
    if (description == null) return const [];
    final points = <String>[];
    for (final raw in description.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (_sectionHeading.hasMatch(line)) break;
      if (_metaLine.hasMatch(line)) continue;
      final text = line.replaceFirst(_bullet, '').trim();
      if (text.isEmpty) continue;
      points.add(text);
      if (points.length == maxPoints) break;
    }
    return points;
  }

  /// The first [maxPoints] instructions. The agency's order is kept.
  static List<String> capActions(final List<String> actions) {
    final cleaned = actions
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();
    return cleaned.length <= maxPoints
        ? cleaned
        : cleaned.sublist(0, maxPoints);
  }

  /// Shown when the agency gave no instruction. Never says "no advice".
  /// "Check [agency] for updates." The second standing point: it points at
  /// the agency, it is not ALRT's own advice.
  static String checkUpdatesLine(final String? agencyName) {
    final name = (agencyName ?? '').trim();
    return name.isEmpty
        ? 'Check official sources for updates.'
        : 'Check $name for updates.';
  }

  /// The agency's instructions, capped at [maxPoints] and padded to at least
  /// [minActions] with standing lines that point at the agency (never ALRT
  /// advice). Order is kept; padding is added after the agency's own points.
  static List<String> actionsWithMinimum(
    final List<String>? actions,
    final String? agencyName,
  ) {
    final out = capActions(actions ?? const <String>[]);
    if (out.isEmpty) out.add(followAgencyLine(agencyName));
    if (out.length < minActions) out.add(checkUpdatesLine(agencyName));
    return out;
  }

  static String followAgencyLine(final String? agencyName) {
    final name = (agencyName ?? '').trim();
    return name.isEmpty
        ? 'If you are near the area, be ready to follow the instructions of '
            'the emergency services.'
        : 'If you are near the area, be ready to follow $name instructions.';
  }
}
