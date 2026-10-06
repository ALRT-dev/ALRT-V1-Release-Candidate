import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';

/// State for the Ask ALRT chat: the transcript, a sending flag and today's
/// allowance as the server reports it.
///
/// Plain immutable class (no freezed) so the feature has no build_runner step.
class AskAlrtProviderState {
  const AskAlrtProviderState({
    this.messages = const <AskAlrtMessage>[],
    this.isSending = false,
    this.dailyLimit,
    this.remainingToday,
    this.limitReached = false,
  });

  /// The chat transcript, oldest first.
  final List<AskAlrtMessage> messages;

  /// True while a question is in flight (renders the thinking bubble and
  /// blocks a second send).
  final bool isSending;

  /// Questions allowed per day on this person's plan (3 Free, 10 ALRT +).
  /// Null until the server has said.
  final int? dailyLimit;

  /// Questions left today. Null until the server has said.
  final int? remainingToday;

  /// True once the server refused a question because today's allowance is
  /// used up.
  final bool limitReached;

  AskAlrtProviderState copyWith({
    final List<AskAlrtMessage>? messages,
    final bool? isSending,
    final int? dailyLimit,
    final int? remainingToday,
    final bool? limitReached,
  }) {
    return AskAlrtProviderState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      remainingToday: remainingToday ?? this.remainingToday,
      limitReached: limitReached ?? this.limitReached,
    );
  }
}
