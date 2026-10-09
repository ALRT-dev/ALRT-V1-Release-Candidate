import 'dart:convert';

/// A locally persisted record of a received push notification, displayed
/// in the Push Inbox screen. The raw FCM payload is stored as JSON so the
/// item can be tapped to navigate to the alert detail.
class PushInboxItem {
  PushInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.hazardId,
    this.severityBand,
    this.payload,
  });

  /// FCM message ID (unique per push).
  final String id;

  /// Notification title (e.g. "Watch and Act — Bushfire near Toowoomba").
  final String title;

  /// Notification body text.
  final String body;

  /// Device-local timestamp when the push was received/displayed.
  final DateTime receivedAt;

  /// The hazard this push relates to, if any. Extracted from the payload
  /// so the inbox item can deep-link to the detail screen.
  final String? hazardId;

  /// Severity band (info / monitor / action / critical) for colouring.
  final String? severityBand;

  /// The raw FCM `data['payload']` JSON string, kept so we can rebuild
  /// a Hazard ID or route target later without changing the schema.
  final String? payload;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        if (hazardId != null) 'hazardId': hazardId,
        if (severityBand != null) 'severityBand': severityBand,
        if (payload != null) 'payload': payload,
      };

  factory PushInboxItem.fromJson(Map<String, dynamic> json) => PushInboxItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String? ?? '',
        receivedAt: DateTime.parse(json['receivedAt'] as String),
        hazardId: json['hazardId'] as String?,
        severityBand: json['severityBand'] as String?,
        payload: json['payload'] as String?,
      );

  /// Serialises the list for SharedPreferences storage.
  static String encodeList(List<PushInboxItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  /// Deserialises the list from SharedPreferences storage.
  static List<PushInboxItem> decodeList(String encoded) {
    final list = jsonDecode(encoded) as List;
    return list
        .map((e) => PushInboxItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
