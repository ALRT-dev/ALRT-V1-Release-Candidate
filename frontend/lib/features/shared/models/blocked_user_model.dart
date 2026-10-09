import 'package:freezed_annotation/freezed_annotation.dart';

part 'blocked_user_model.freezed.dart';
part 'blocked_user_model.g.dart';

/// An account this user has blocked.
///
/// Carries the bare minimum to render an undo list: the id being filtered
/// on, and a name so the blocker can tell which block is which. Nothing
/// else about a blocked person is fetched or stored.
@freezed
abstract class BlockedUser with _$BlockedUser {
  const factory BlockedUser({
    required final String userId,
    @Default('Community member') final String name,
    final DateTime? blockedAt,
  }) = _BlockedUser;

  factory BlockedUser.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserFromJson(json);
}

@freezed
abstract class BlockedUsersResponse with _$BlockedUsersResponse {
  const factory BlockedUsersResponse({
    @Default(<BlockedUser>[]) final List<BlockedUser> blocked,
  }) = _BlockedUsersResponse;

  factory BlockedUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockedUsersResponseFromJson(json);
}

/// Why a report is being flagged. Fixed list, no free text: it keeps the
/// flag useful for triage and stops the flag becoming a channel for abuse.
enum HazardFlagReason {
  inappropriate('inappropriate', 'Inappropriate or offensive'),
  misleading('misleading', 'Misleading or false'),
  spam('spam', 'Spam or advertising'),
  harassment('harassment', 'Harassment of a person'),
  other('other', 'Something else');

  const HazardFlagReason(this.id, this.label);

  /// Sent to the backend; must match the HazardFlagReason enum there.
  final String id;

  /// What the person choosing it reads.
  final String label;
}
