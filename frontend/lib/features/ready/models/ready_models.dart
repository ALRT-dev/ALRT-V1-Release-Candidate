/// Plain models for the Ready tab backend endpoints.
///
/// These avoid freezed/codegen so the build can run without build_runner.
/// JSON parsing is manual — the backend returns camelCase keys.

class ReadySummary {
  const ReadySummary({
    required this.hasPlan,
    required this.hasDrill,
    required this.planCount,
    required this.drillCount,
  });

  factory ReadySummary.fromJson(Map<String, dynamic> json) => ReadySummary(
        hasPlan: json['hasPlan'] as bool? ?? false,
        hasDrill: json['hasDrill'] as bool? ?? false,
        planCount: json['planCount'] as int? ?? 0,
        drillCount: json['drillCount'] as int? ?? 0,
      );

  final bool hasPlan;
  final bool hasDrill;
  final int planCount;
  final int drillCount;
}

class PlanItem {
  const PlanItem({required this.text, required this.checked});

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
        text: json['text'] as String? ?? '',
        checked: json['checked'] as bool? ?? false,
      );

  final String text;
  final bool checked;

  Map<String, dynamic> toJson() => {'text': text, 'checked': checked};

  PlanItem copyWith({String? text, bool? checked}) => PlanItem(
        text: text ?? this.text,
        checked: checked ?? this.checked,
      );
}

class EmergencyPlan {
  const EmergencyPlan({
    required this.id,
    required this.title,
    this.meetingPoint,
    this.evacuationRoute,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.drillCount = 0,
  });

  factory EmergencyPlan.fromJson(Map<String, dynamic> json) => EmergencyPlan(
        id: json['id'] as String,
        title: json['title'] as String,
        meetingPoint: json['meetingPoint'] as String?,
        evacuationRoute: json['evacuationRoute'] as String?,
        notes: json['notes'] as String?,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        drillCount: (json['_count'] as Map<String, dynamic>?)?['drills']
                as int? ??
            0,
      );

  final String id;
  final String title;
  final String? meetingPoint;
  final String? evacuationRoute;
  final String? notes;
  final List<PlanItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int drillCount;
}

class EmergencyDrill {
  const EmergencyDrill({
    required this.id,
    required this.title,
    this.planId,
    this.notes,
    required this.completedAt,
    this.durationMinutes,
    required this.createdAt,
  });

  factory EmergencyDrill.fromJson(Map<String, dynamic> json) => EmergencyDrill(
        id: json['id'] as String,
        title: json['title'] as String,
        planId: json['planId'] as String?,
        notes: json['notes'] as String?,
        completedAt: DateTime.parse(json['completedAt'] as String),
        durationMinutes: json['durationMinutes'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String title;
  final String? planId;
  final String? notes;
  final DateTime completedAt;
  final int? durationMinutes;
  final DateTime createdAt;
}
