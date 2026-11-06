import 'package:flutter/material.dart';

/// Source facts, official actions and ALRT suggestions render separately.
class AgencyContentSections extends StatelessWidget {
  const AgencyContentSections({
    super.key,
    required this.content,
    this.sourceName,
    this.officialIntro,
    this.severityColor,
  });
  final Map<String, dynamic> content;
  final String? sourceName;
  final String? officialIntro;
  final Color? severityColor;

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
                ? const Color(0xFFD8E3EC)
                : const Color(0xFFF1D8C3),
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
                child: (text == 'ALRT suggestions' || text == 'Agency instructions' || text.endsWith(' advises'))
                    ? Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5C5C66)))
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
                          fontWeight: FontWeight.w500,
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
    final agency = sourceName?.trim() ?? '';
    // Facts already come from grounded extraction; do not repeat a generated intro.
    final factLines = facts.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (level is String && level.isNotEmpty)
          _section('AGENCY WARNING', [level]),
        if (areas.isNotEmpty && !typedIncident)
          _section('AFFECTED AREA', areas),
        if (factLines.isNotEmpty) _section('WHAT WE KNOW', factLines),
        if (actions.isNotEmpty || suggestions.isNotEmpty)
          _section(
            'WHAT TO DO',
            [
              if (actions.isNotEmpty) ...[
                agency.isEmpty ? 'Agency instructions' : '$agency advises',
                ...actions,
              ],
              if (suggestions.isNotEmpty && actions.length < 2) ...[
                'ALRT suggestions',
                ...suggestions.take((2 - actions.length).clamp(0, 2)),
              ],
            ],
            subtitle: suggestions.isNotEmpty && actions.length < 2
                ? 'ALRT suggestions are general guidance, separate from agency instructions.'
                : null,
          ),
        if (originalSource is String && originalSource.trim().isNotEmpty)
          if (typedIncident)
            Card(
              elevation: 0,
              color: Colors.white,
              child: ExpansionTile(
                title: const Text('Original source details'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [Text(originalSource)],
              ),
            )
          else
            _section('ORIGINAL SOURCE DETAILS', [originalSource]),
      ],
    );
  }
}
