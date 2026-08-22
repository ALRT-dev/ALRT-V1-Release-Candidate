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
  });

  /// Who sent the message.
  final AskAlrtRole role;

  /// The display text of the message.
  final String text;

  /// The nearby alerts that were passed to the backend as grounding context
  /// for this answer. Rendered as outlined source chips under the assistant
  /// bubble. Empty for user messages and for answers with no alert context.
  final List<Hazard> groundingAlerts;

  /// Whether this message was written by the assistant.
  bool get isAssistant => role == AskAlrtRole.assistant;
}
