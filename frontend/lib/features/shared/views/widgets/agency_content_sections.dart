import 'package:flutter/material.dart';

/// Source facts, official actions and ALRT suggestions render separately.
class AgencyContentSections extends StatelessWidget {
  const AgencyContentSections({
    super.key,
    required this.content,
    this.sourceName,
    this.officialIntro,
    this.severityColor,
    this.showOriginalSource = true,
  });
  final Map<String, dynamic> content;
  final String? sourceName;
  final String? officialIntro;
  final Color? severityColor;
  final bool showOriginalSource;

  List<String> _lines(String key) {
    final value = content[key];
    return value is List
        ? value.whereType<String>().where((x) => x.trim().isNotEmpty).toList()
        : [];
  }

  /// One section in the Detail board's language: a white card (radius 18),
  /// the V3 orange label, an optional grey line under it, dotted lines.
  Widget _section(String title, List<String> lines, {String? subtitle}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: title == 'WHAT WE KNOW'
                ? const Color(0xFF799AB5)
                : const Color(0xFFE7813C),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFB84500),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5C5C66)),
              ),
            ],
            const SizedBox(height: 8),
            for (final text in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child:
                    (text == 'ALRT suggestions' ||
                        text == 'Agency instructions' ||
                        text.endsWith(' advises'))
                    ? Text(
                        text,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5C5C66),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 7),
                            decoration: BoxDecoration(
                              color: severityColor ?? const Color(0xFFFF7900),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1A1A22),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final facts = _lines('facts'), areas = _lines('affectedAreas');
    final actions = _lines('officialActions'),
        suggestions = _lines('alrtSuggestions');
    final level = content['nativeLevel'];
    final typedIncident = content['extractionMethod'] == 'dfes-incident-fields';
    final originalSource =
        content['originalSourceText'] ?? content['sourceDescription'];
    final agency =
        (content['issuingAgency'] is String
                ? content['issuingAgency'] as String
                : sourceName)
            ?.trim() ??
        '';
    // Facts already come from grounded extraction; do not repeat a generated intro.
    final factLines = facts.take(4).toList();
    final limitations = content['sourceLimitations'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (level is String && level.isNotEmpty)
          _section('AGENCY WARNING', [level]),
        if (areas.isNotEmpty && !typedIncident)
          _section('AFFECTED AREA', areas),
        if (factLines.isNotEmpty) ...[
          _section('WHAT WE KNOW', factLines),
          if (limitations is String && limitations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                limitations,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF5C5C66),
                ),
              ),
            ),
        ],
        _section(
          'WHAT TO DO',
          [
            if (actions.isNotEmpty) ...[
              agency.isEmpty ? 'Agency instructions' : '$agency advises',
              ...actions.take(4),
            ],
            if (suggestions.isNotEmpty && actions.isEmpty) ...[
              'ALRT suggestions',
              ...suggestions.take(4),
            ],
            if (actions.isEmpty && suggestions.isEmpty)
              content['sourceAdviceStatus'] == 'not-in-incident-feed'
                  ? 'This incident feed contains no agency instructions. Open the source for any newer warning or advice.'
                  : 'Agency instructions are not available in this view. Check the original source details for the full information.',
          ],
          subtitle: suggestions.isNotEmpty && actions.isEmpty
              ? 'General guidance from ALRT; not agency instructions.'
              : null,
        ),
        if (actions.length > 4)
          Card(
            elevation: 0,
            color: Colors.white,
            child: ExpansionTile(
              title: Text('More agency instructions (${actions.length - 4})'),
              children: [
                _section('AGENCY INSTRUCTIONS', actions.skip(4).toList()),
              ],
            ),
          ),
        if (showOriginalSource && originalSource is String)
          AgencyOriginalSourceDetails(text: originalSource),
      ],
    );
  }
}

class AgencyOriginalSourceDetails extends StatelessWidget {
  const AgencyOriginalSourceDetails({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => text.trim().isEmpty
      ? const SizedBox.shrink()
      : Card(
          elevation: 0,
          color: Colors.white,
          child: ExpansionTile(
            title: const Text('Original source details'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [Text(text)],
          ),
        );
}
