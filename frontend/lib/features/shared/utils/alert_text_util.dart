/// Cleans an agency's verbatim text for the alert screen.
///
/// Agencies such as DFES publish ONE block that holds the facts, their own
/// "WHAT TO DO" list, road closures and more. The screen has separate
/// sections for those, so "What we know" must hold the facts only and
/// "What to do" must not be repeated inside it.
library;

import 'package:hazard_app/features/shared/utils/alert_guidance_library.dart';

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
    return whatWeKnowAllPoints(description).take(maxPoints).toList();
  }

  /// All the facts the source published, uncapped. Used by the "Show all"
  /// expander so nothing the agency wrote is ever hidden.
  static List<String> whatWeKnowAllPoints(final String? description) {
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
    }
    return points;
  }

  /// One alert display (owner review, 13 November 2026). An official alert
  /// stored without structured content (older records, or written while no
  /// Alert Templates snapshot was published) is turned into the same
  /// content map the structured card reads, so every official alert shows
  /// the same sections in the same order:
  /// - What we know: the issued line, then the source's own facts, or the
  ///   plain summary when the source gives fewer than two.
  /// - What to do: the agency's own lines ("X advises: ..."), then ALRT
  ///   reviewed lines from the on-device library, only when the agency
  ///   gave fewer than two, and never a leave, evacuate, shelter, stay or
  ///   return direction (9 November 2026 rule).
  static Map<String, dynamic> legacyDisplayContent({
    required final String? description,
    final String? aiSummary,
    final List<String>? callsToAction,
    final String? nativeLevel,
    final String? issuedLine,
    final String? hazardBucket,
  }) {
    final facts = <String>[
      if (issuedLine != null && issuedLine.trim().isNotEmpty) issuedLine.trim(),
    ];
    for (final point in whatWeKnowAllPoints(description)) {
      if (facts.length >= 4) break;
      if (!facts.contains(point)) facts.add(point);
    }
    if (facts.length < 2 && aiSummary != null) {
      for (final point in _summaryPoints(aiSummary)) {
        if (facts.length >= 4) break;
        if (!facts.contains(point)) facts.add(point);
      }
    }

    final official = <String>[];
    final alrt = <String>[];
    String? agency;
    for (final raw in callsToAction ?? const <String>[]) {
      final line = raw.trim();
      if (line.isEmpty || _pipelineFiller.hasMatch(line)) continue;
      final lead = _agencyLead.firstMatch(line);
      if (lead != null) {
        agency ??= lead.group(1)?.trim();
        official.add(line.substring(lead.end).trim());
      }
      // Unprefixed lines on older records were written under earlier rules
      // and never reviewed, so they are not shown (as before); ALRT advice
      // here comes only from the reviewed on-device list below.
    }
    if (official.length + alrt.length < 2) {
      for (final row in AlertGuidanceLibrary.considerRows(hazardBucket)) {
        if (official.length + alrt.length >= 2) break;
        if (_movementWord.hasMatch(row) || alrt.contains(row)) continue;
        alrt.add(row);
      }
    }

    return {
      'schemaVersion': 1,
      'facts': facts,
      'affectedAreas': const <String>[],
      'nativeLevel': nativeLevel,
      'officialActions': official,
      'alrtSuggestions': alrt,
      if (agency != null && agency.isNotEmpty) 'issuingAgency': agency,
      if (description != null) 'sourceDescription': description,
      'extractionMethod': 'legacy-display',
    };
  }

  static final RegExp _agencyLead = RegExp(
    r'^(.{1,60}?) advises:\s*',
    caseSensitive: false,
  );
  static final RegExp _pipelineFiller = RegExp(
    r'^\s*(if you are (near|in|around) (the|this) area,?\s*)?be ready to follow\b.*instructions\.?\s*$',
    caseSensitive: false,
  );
  static final RegExp _movementWord = RegExp(
    r'\b(leave|leaving|evacuat\w*|shelter\w*|stay|return\w*|go to)\b',
    caseSensitive: false,
  );
  static final RegExp _fieldLine = RegExp(r"^[A-Za-z][A-Za-z /&()'-]{1,30}:\s");

  static List<String> _summaryPoints(final String summary) => summary
      .split(RegExp(r'\n+|(?<=[.!?])\s+(?=[A-Z])'))
      .map((line) => line.replaceFirst(_bullet, '').trim())
      .where((line) => line.length >= 15 && !_fieldLine.hasMatch(line))
      .toList();

  /// The first "WHAT WE KNOW" line for an official alert: who issued it and
  /// what kind of incident it is, at which place. e.g. "DFES has issued a
  /// bushfire incident at Toodyay." Falls back to a plain agency line when
  /// the type or place is unknown, and is never empty.
  static String issuedLine(
    final String? agencyName,
    final String? incidentType,
    final String? locationName,
  ) {
    final agency = (agencyName ?? '').trim();
    final type = (incidentType ?? '').trim().toLowerCase();
    final place = (locationName ?? '').trim();
    if (type.isEmpty) {
      return agency.isEmpty
          ? 'An incident has been reported.'
          : '$agency has reported an incident.';
    }
    final typePhrase = type.startsWith('incident') ? type : '$type incident';
    if (agency.isEmpty) {
      return place.isEmpty
          ? 'A $typePhrase has been reported.'
          : 'A $typePhrase has been reported at $place.';
    }
    return place.isEmpty
        ? '$agency has issued a $typePhrase.'
        : '$agency has issued a $typePhrase at $place.';
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
    // A report alone is not actionable. Add what the reader can do now, so a
    // community alert never reads as just "an incident has occurred".
    if (out.length < maxPoints) {
      out.add(
        'If you are near the area, take care and check for official updates.',
      );
    }
    return out.take(maxPoints).toList();
  }

  /// Guarantees at least [min] relevant, actionable points. When the source
  /// gave fewer (a terse agency, an alert with nothing beyond its headline),
  /// it tops up with ALRT's hazard-specific actionable guidance so the section
  /// never reads as a single vague "an incident has occurred" line.
  static List<String> ensureMinPoints(
    final List<String> points,
    final String? bucket,
    final int min,
  ) {
    if (points.length >= min) return points.take(min).toList();
    final out = [...points];
    for (final line in AlertGuidanceLibrary.considerRows(bucket)) {
      if (out.length >= min) break;
      if (out.contains(line)) continue;
      out.add(line);
    }
    return out;
  }

  /// The first [maxPoints] instructions, ranked by urgency (Tier 1 life-safety
  /// first) then capped. The agency's own words are never changed — only their
  /// display order — so a "leave now" buried at #5 still surfaces. The rest of
  /// the agency's list is reachable behind the "Show all" expander.
  static List<String> capActions(final List<String> actions) {
    final ranked = AlertGuidanceLibrary.rankActions(actions);
    return ranked.length <= maxPoints
        ? ranked
        : ranked.sublist(0, maxPoints);
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

  /// The one standing line on every alert (owner ruling): no number, no
  /// agency, never a promise that ALRT contacts anyone.
  static const String standingEmergencyLine =
      'If you are experiencing an emergency, call your local emergency number.';

  static String followAgencyLine(final String? agencyName) {
    final name = (agencyName ?? '').trim();
    return name.isEmpty
        ? 'If you are near the area, be ready to follow the instructions of '
            'the emergency services.'
        : 'If you are near the area, be ready to follow $name instructions.';
  }
}
