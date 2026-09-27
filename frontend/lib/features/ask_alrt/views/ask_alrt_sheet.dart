import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';
import 'package:hazard_app/features/ask_alrt/providers/ask_alrt_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/voice/voice_search_mic_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Opens the Ask ALRT assistant as a dark bottom sheet.
///
/// The entry point signature is stable so callers (the map rail) never change.
Future<void> showAskAlrtSheet(final BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AskAlrtSheet(),
  );
}

/// The Ask ALRT gradient (badge, user bubbles, send button).
const _askAlrtGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF8C00), Color(0xFFFF2020)],
);

const _sheetBackground = Color(0xFF141416);
const _assistantBubbleColor = Color(0xFF232326);
const _inputFillColor = Color(0xFF1E1E21);
const _sourceChipBorderColor = Color(0xFFB84500);
const _sourceChipTextColor = Color(0xFFFFB020);
const _disclaimerBackground = Color(0xFF3A1215);
const _disclaimerTextColor = Color(0xFFFF9B9B);

/// Starter questions shown while the chat is still empty.
const _suggestedQuestions = <String>[
  'What does Watch and Act mean?',
  'How do I prepare for a bushfire?',
  'What should be in an emergency kit?',
];

/// The Ask ALRT grounded-chat sheet (Sarah's V3 dark chat design).
class AskAlrtSheet extends ConsumerStatefulWidget {
  const AskAlrtSheet({super.key});

  @override
  ConsumerState<AskAlrtSheet> createState() => _AskAlrtSheetState();
}

class _AskAlrtSheetState extends ConsumerState<AskAlrtSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(final String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (ref.read(providerOfAskAlrt).isSending) return;
    _inputController.clear();
    ref.read(providerOfAskAlrt.notifier).ask(trimmed);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerOfAskAlrt);

    ref.listen(providerOfAskAlrt, (previous, next) {
      final messagesChanged =
          (previous?.messages.length ?? 0) != next.messages.length;
      if (messagesChanged || previous?.isSending != next.isSending) {
        _scrollToBottom();
      }
    });

    // Keep the input above the keyboard: pad by the view inset and shrink the
    // sheet by the same amount so the total never exceeds the screen.
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = (maxSheetHeight - bottomInset)
        .clamp(maxSheetHeight * 0.4, maxSheetHeight)
        .toDouble();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: _sheetBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  16.spMin,
                  10.spMin,
                  16.spMin,
                  14.spMin,
                ),
                itemCount: state.messages.length + (state.isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.messages.length) {
                    return const _ThinkingBubble();
                  }
                  return _MessageBubble(message: state.messages[index]);
                },
              ),
            ),
            if (state.messages.isEmpty && !state.isSending)
              _buildSuggestionChips(),
            _buildDisclaimer(),
            _buildInputRow(state.isSending),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40.spMin,
      height: 4.spMin,
      margin: EdgeInsets.only(top: 10.spMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(2.spMin),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.spMin, 14.spMin, 16.spMin, 12.spMin),
      child: Row(
        children: [
          Container(
            width: 42.spMin,
            height: 42.spMin,
            decoration: const BoxDecoration(
              gradient: _askAlrtGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.sparkles,
              size: 20.spMin,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask ALRT',
                  style: TextStyle(
                    fontSize: 17.spMin,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  'Answers grounded in alerts near you',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.spMin),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 32.spMin,
              height: 32.spMin,
              decoration: const BoxDecoration(
                color: _assistantBubbleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.x,
                size: 16.spMin,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    return SizedBox(
      height: 38.spMin,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.spMin),
        itemCount: _suggestedQuestions.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.spMin),
        itemBuilder: (context, index) {
          final question = _suggestedQuestions[index];
          return InkWell(
            onTap: () => _send(question),
            borderRadius: BorderRadius.circular(19.spMin),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.spMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _inputFillColor,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(19.spMin),
              ),
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.spMin),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 8.spMin),
      color: _disclaimerBackground,
      child: Text(
        "If you're in immediate danger, call your local emergency number now. "
        'ALRT is information, not emergency services.',
        style: TextStyle(
          fontSize: 11.spMin,
          color: _disclaimerTextColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildInputRow(final bool isSending) {
    // The home indicator sits under the sheet when the keyboard is closed
    // (padding.bottom drops to zero once the keyboard covers it), so the
    // send button needs that clearance or it reads as cut off.
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.spMin,
        10.spMin,
        16.spMin,
        16.spMin + bottomSafeArea,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          VoiceSearchMicButton(
            onTranscript: (text) {
              // Spoken questions go straight to Ask ALRT.
              _send(text);
            },
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              style: TextStyle(
                fontSize: 13.5.spMin,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: _inputFillColor,
                hintText: 'Ask about alerts near you',
                hintStyle: TextStyle(
                  fontSize: 13.5.spMin,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                  vertical: 12.spMin,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.spMin),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.spMin),
          Opacity(
            opacity: isSending ? 0.5 : 1,
            child: InkWell(
              onTap: () => _send(_inputController.text),
              customBorder: const CircleBorder(),
              child: Container(
                width: 44.spMin,
                height: 44.spMin,
                decoration: const BoxDecoration(
                  gradient: _askAlrtGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.arrowUp,
                  size: 20.spMin,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single chat message: gradient bubble on the right for the user, dark
/// bubble with a sparkle avatar (plus optional source chips) on the left for
/// the assistant.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AskAlrtMessage message;

  @override
  Widget build(BuildContext context) {
    if (!message.isAssistant) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.only(top: 10.spMin, left: 48.spMin),
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 10.spMin,
          ),
          decoration: BoxDecoration(
            gradient: _askAlrtGradient,
            borderRadius: BorderRadius.circular(18.spMin),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 13.5.spMin,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.spMin, right: 34.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SparkleAvatar(),
          SizedBox(width: 8.spMin),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.spMin,
                    vertical: 10.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: _assistantBubbleColor,
                    borderRadius: BorderRadius.circular(18.spMin),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 13.5.spMin,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                if (message.groundingAlerts.isNotEmpty) ...[
                  SizedBox(height: 6.spMin),
                  Wrap(
                    spacing: 6.spMin,
                    runSpacing: 6.spMin,
                    children: [
                      for (final alert in message.groundingAlerts)
                        _SourceChip(alert: alert),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The small orange sparkle avatar next to assistant bubbles.
class _SparkleAvatar extends StatelessWidget {
  const _SparkleAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.spMin,
      height: 24.spMin,
      decoration: const BoxDecoration(
        gradient: _askAlrtGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.sparkles,
        size: 12.spMin,
        color: Colors.white,
      ),
    );
  }
}

/// Outlined pill naming an alert the answer was grounded in: the
/// source-system shape icon (V3 spec: shape says which system) + title.
class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.alert});

  final Hazard alert;

  @override
  Widget build(BuildContext context) {
    final shapeIcon = AlertCardStyle.systemShapeIcon(
      isAws: alert.isAwsCompliant == true,
      isOfficial: alert.source != null,
      isGlobalHumanitarian: alert.isGlobalHumanitarian,
      isAlrtIntel: alert.isAlrtIntel,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 5.spMin),
      decoration: BoxDecoration(
        border: Border.all(color: _sourceChipBorderColor, width: 1.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shapeIcon,
            size: 11.spMin,
            color: _sourceChipTextColor,
          ),
          SizedBox(width: 5.spMin),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 180.spMin),
            child: Text(
              alert.title?.trim().isNotEmpty == true
                  ? alert.title!.trim()
                  : 'Nearby alert',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.spMin,
                fontWeight: FontWeight.w600,
                color: _sourceChipTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The subtle assistant-side "thinking" indicator shown while waiting.
class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SparkleAvatar(),
          SizedBox(width: 8.spMin),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.spMin,
              vertical: 12.spMin,
            ),
            decoration: BoxDecoration(
              color: _assistantBubbleColor,
              borderRadius: BorderRadius.circular(18.spMin),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var dot = 0; dot < 3; dot++) ...[
                      if (dot > 0) SizedBox(width: 4.spMin),
                      _buildDot(dot),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(final int index) {
    // Stagger the three dots a third of a cycle apart.
    final phase = (_controller.value + index / 3) % 1;
    // Rise and fall between 0.25 and 1.0 opacity.
    final wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
    return Opacity(
      opacity: 0.25 + 0.75 * wave,
      child: Container(
        width: 6.spMin,
        height: 6.spMin,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
