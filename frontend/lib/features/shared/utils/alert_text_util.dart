/// Cleans an agency's verbatim text for the alert screen.
///
/// Agencies such as DFES publish ONE block that holds the facts, their own
/// "WHAT TO DO" list, road closures and more. The screen has separate
/// sections for those, so "What we know" must hold the facts only and
/// "What to do" must not be repeated inside it.
abstract final class AlertTextUtil {
  /// Most points either section shows.
  static const int maxPoints = 3;

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

  /// What we know for a community report: what was reported, what the
  /// reporter wrote (if anything), and that it is unverified. Always 1 to
  /// [maxPoints] points, never empty.
  static List<String> communityPoints(
    final String? title,
    final String? description,
  ) {
    final out = <String>[];
    final t = (title ?? '').trim();
    out.add(
      t.isEmpty
          ? 'A community member has reported an incident nearby.'
          : 'A community member has reported: $t.'.replaceAll('..', '.'),
    );
    final d = (description ?? '').trim();
    if (d.isNotEmpty && d.toLowerCase() != t.toLowerCase()) {
      out.add(d.length > 160 ? '${d.substring(0, 157).trim()}...' : d);
    }
    out.add('This report is unverified and has not been confirmed by an official source.');
    return out.take(maxPoints).toList();
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

  /// Shown only when the agency gave no instruction. Points at the agency;
  /// it is never ALRT's own advice and never says "no advice".
  /// What we know always shows. When the source published nothing beyond
  /// the headline, this one honest line stands in. It adds no facts.
  static String noDetailsLine(final String? agencyName) {
    final name = (agencyName ?? '').trim();
    return name.isEmpty
        ? 'The source has not published further details yet.'
        : '$name has not published further details yet.';
  }

  static String followAgencyLine(final String? agencyName) {
    final name = (agencyName ?? '').trim();
    return name.isEmpty
        ? 'If you are near the area, be ready to follow the instructions of '
            'the emergency services.'
        : 'If you are near the area, be ready to follow $name instructions.';
  }
}
