import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/notification/models/push_inbox_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'push_inbox_items';

/// Maximum number of items to keep in the inbox. Oldest items are
/// dropped first.
const _maxItems = 200;

final providerOfPushInbox =
    StateNotifierProvider<PushInboxNotifier, List<PushInboxItem>>(
  (ref) => PushInboxNotifier(),
);

class PushInboxNotifier extends StateNotifier<List<PushInboxItem>> {
  PushInboxNotifier() : super(const []) {
    _load();
    loadReadIds();
  }

  /// Loads persisted items from SharedPreferences.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        state = PushInboxItem.decodeList(raw);
      }
    } catch (_) {
      // Corrupted storage — start fresh.
    }
  }

  /// Saves current state to SharedPreferences.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, PushInboxItem.encodeList(state));
    } catch (_) {
      // Best-effort storage; if it fails, the item is still in memory
      // for the current session.
    }
  }

  /// Records a received push notification. Called from NotificationService
  /// when a foreground or background message is received.
  Future<void> record(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] as String?;
    final body =
        message.notification?.body ?? message.data['body'] as String?;

    // Skip notifications without meaningful content.
    if ((title == null || title.isEmpty) &&
        (body == null || body.isEmpty)) {
      return;
    }

    final id = message.messageId ??
        message.sentTime?.millisecondsSinceEpoch.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Don't store duplicates.
    if (state.any((item) => item.id == id)) return;

    // Extract hazardId and severityBand from payload if available.
    String? hazardId;
    String? severityBand;
    final payloadRaw = message.data['payload'];
    if (payloadRaw is String && payloadRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(payloadRaw);
        if (decoded is Map<String, dynamic>) {
          hazardId = decoded['id'] as String? ??
              decoded['hazardId'] as String?;
          severityBand =
              (decoded['severityBand'] as String?)?.toLowerCase();
        }
      } catch (_) {
        // Unparseable payload; carry on without it.
      }
    }

    final item = PushInboxItem(
      id: id,
      title: title ?? '',
      body: body ?? '',
      receivedAt: message.sentTime ?? DateTime.now(),
      hazardId: hazardId,
      severityBand: severityBand,
      payload: payloadRaw is String ? payloadRaw : null,
    );

    // Prepend newest first, cap at _maxItems.
    final updated = [item, ...state];
    if (updated.length > _maxItems) {
      state = updated.sublist(0, _maxItems);
    } else {
      state = updated;
    }
    await _persist();
  }

  /// Number of items that arrived since the user last opened the inbox.
  int get unreadCount => state.where((i) => !_readIds.contains(i.id)).length;

  /// Whether the item with [id] has been read.
  bool isRead(String id) => _readIds.contains(id);

  final Set<String> _readIds = {};

  /// Marks all current items as read (when the inbox screen is opened).
  Future<void> markAllRead() async {
    _readIds.addAll(state.map((i) => i.id));
    // Persist the read state.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('push_inbox_read_ids', _readIds.toList());
    } catch (_) {}
  }

  /// Loads read IDs from storage.
  Future<void> loadReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('push_inbox_read_ids');
      if (ids != null) _readIds.addAll(ids);
    } catch (_) {}
  }
}
