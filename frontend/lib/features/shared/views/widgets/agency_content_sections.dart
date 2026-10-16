import 'package:flutter/material.dart';

/// Source facts, official actions and ALRT suggestions render separately.
class AgencyContentSections extends StatelessWidget {
  const AgencyContentSections({
    super.key,
    required this.content,
    this.sourceName,
  });
  final Map<String, dynamic> content;
  final String? sourceName;

  List<String> _lines(String key) {
    final value = content[key];
    return value is List
        ? value.whereType<String>().where((x) => x.trim().isNotEmpty).toList()
        : [];
  }

  Widget _section(String title, List<String> lines) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFB84500),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final text in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $text', style: const TextStyle(height: 1.5)),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final facts = _lines('facts'), areas = _lines('affectedAreas');
    final actions = _lines('officialActions'),
        suggestions = _lines('alrtSuggestions');
    final level = content['nativeLevel'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (level is String && level.isNotEmpty)
          _section('AGENCY WARNING', [level]),
        if (areas.isNotEmpty) _section('AFFECTED AREA', areas),
        if (facts.isNotEmpty) _section('WHAT WE KNOW', facts),
        if (actions.isNotEmpty)
          _section('WHAT TO DO - ${sourceName ?? 'ISSUING AGENCY'}', actions),
        if (suggestions.isNotEmpty) _section('ALRT SUGGESTIONS', suggestions),
      ],
    );
  }
}
