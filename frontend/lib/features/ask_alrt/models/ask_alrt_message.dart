import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// Who authored an Ask ALRT chat message.
enum AskAlrtRole {
  /// The person asking a question.
  user,

  /// The Ask ALRT assistant (or a local fallback bubble).
  assistant,
}

/// A single message in the Ask ALRT chat.
///
/// Deliberately a plain immutable class (no freezed) so the feature has no
/// build_runner dependency.
class AskAlrtMessage {
  const AskAlrtMessage({
    required this.role,
    required this.text,
    this.groundingAlerts = const <Hazard>[],
    this.freeAnswer = false,
  });

  /// Who sent the message.
  final AskAlrtRole role;

  /// The display text of the message.
  final String text;

  /// The nearby alerts the backend actually cited when answering this
  /// question (a subset of whatever was sent as context - not everything
  /// sent, only what the model said it relied on). Rendered as outlined
  /// source chips under the assistant bubble. Empty for user messages and
  /// for answers that didn't cite any specific alert.
  final List<Hazard> groundingAlerts;

  /// True when the answer came from the ALRT library or the emergency
  /// number lookup, which never count toward the daily allowance (R03).
  /// The sheet says so under the answer.
  final bool freeAnswer;

  /// Whether this message was written by the assistant.
  bool get isAssistant => role == AskAlrtRole.assistant;
}
