import 'package:flutter/material.dart';

/// Source facts, official actions and ALRT suggestions render separately.
class AgencyContentSections extends StatelessWidget {
  const AgencyContentSections({
    super.key,
    required this.content,
    this.sourceName,
    this.officialIntro,
  });
  final Map<String, dynamic> content;
  final String? sourceName;
  final String? officialIntro;

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9A9AA2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF3A3A42),
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
    final agency = sourceName?.trim() ?? '';
    final intro = officialIntro?.trim();
    final factLines = [
      if (intro != null && intro.isNotEmpty) intro,
      ...facts.where((line) => line.trim() != intro),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (level is String && level.isNotEmpty)
          _section('AGENCY WARNING', [level]),
        if (areas.isNotEmpty) _section('AFFECTED AREA', areas),
        if (factLines.isNotEmpty) _section('WHAT WE KNOW', factLines),
        if (actions.isNotEmpty)
          _section(
            'WHAT TO DO',
            actions,
            subtitle: agency.isEmpty ? null : '$agency, word for word',
          ),
        if (suggestions.isNotEmpty && actions.isEmpty)
          _section(
            'WHAT TO DO',
            suggestions,
            subtitle: 'General guidance from ALRT, not part of the official '
                'warning.',
          ),
      ],
    );
  }
}
