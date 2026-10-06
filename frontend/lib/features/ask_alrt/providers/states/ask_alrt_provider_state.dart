import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';

/// State for the Ask ALRT chat: the transcript plus a sending flag.
///
/// Plain immutable class (no freezed) so the feature has no build_runner step.
class AskAlrtProviderState {
  const AskAlrtProviderState({
    this.messages = const <AskAlrtMessage>[],
    this.isSending = false,
  });

  /// The chat transcript, oldest first.
  final List<AskAlrtMessage> messages;

  /// True while a question is in flight (renders the thinking bubble and
  /// blocks a second send).
  final bool isSending;

  AskAlrtProviderState copyWith({
    final List<AskAlrtMessage>? messages,
    final bool? isSending,
  }) {
    return AskAlrtProviderState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}
