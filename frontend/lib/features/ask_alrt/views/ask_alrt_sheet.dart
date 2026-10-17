import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';
import 'package:hazard_app/features/ask_alrt/providers/ask_alrt_provider.dart';
import 'package:hazard_app/features/ask_alrt/providers/states/ask_alrt_provider_state.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Opens the Ask ALRT assistant as a bottom sheet (prototype boards
/// "AskALRT" and "AskALRT-Answer", light sheet in the boards' language).
///
/// The entry point signature is stable so callers never change.
///
/// [initialQuestion] is asked as soon as the sheet opens (a question said to
/// Speak to ALRT); it counts the same as a typed one.
Future<void> showAskAlrtSheet(
  final BuildContext context, {
  final String? initialQuestion,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AskAlrtSheet(initialQuestion: initialQuestion),
  );
}

/// The Ask ALRT badge gradient (boards: #FF6B00 to #FF0004).
const _askAlrtGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6B00), Color(0xFFFF0004)],
);

const _ink = Color(0xFF1C1C1E);
const _muted = Color(0xFF5C5C66);
const _brandOrange = Color(0xFFE8622A);
const _fieldBorder = Color(0xFFE3E6EA);
const _questionTint = Color(0xFFFFF1E8);
const _noteTint = Color(0xFFF0EEEA);
const _noteText = Color(0xFF3A3A42);

/// The Ask ALRT grounded-question sheet.
class AskAlrtSheet extends ConsumerStatefulWidget {
  const AskAlrtSheet({super.key, this.initialQuestion});

  /// Asked once when the sheet opens, if given.
  final String? initialQuestion;

  @override
  ConsumerState<AskAlrtSheet> createState() => _AskAlrtSheetState();
}

class _AskAlrtSheetState extends ConsumerState<AskAlrtSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final question = widget.initialQuestion;
    if (question != null && question.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(question);
      });
    }
  }

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

  /// ALRT Free when the server says the allowance is the Free one.
  static bool _isFree(final AskAlrtProviderState state) =>
      (state.dailyLimit ?? AskAlrtProvider.freeDailyLimit) <=
      AskAlrtProvider.freeDailyLimit;

  /// "3 of 3 left today", once the server has said.
  static String? _quotaPill(final AskAlrtProviderState state) {
    final limit = state.dailyLimit;
    final remaining = state.remainingToday;
    if (limit == null || remaining == null) return null;
    return '${remaining.clamp(0, limit)} of $limit left today';
  }

  /// The first suggestion names the most serious official warning nearby,
  /// as on the board; the other two are always the same.
  List<String> _suggestions() {
    List<Hazard> hazards;
    try {
      hazards = ref.read(providerOfMap).hazards;
    } catch (_) {
      hazards = const <Hazard>[];
    }
    final lead = hazards
        .where((h) => !h.isUserReported)
        .where(
          (h) =>
              h.severityBand == HazardSeverityBand.critical ||
              h.severityBand == HazardSeverityBand.action,
        )
        .where((h) => (h.title ?? '').trim().isNotEmpty)
        .firstOrNull;
    String first = 'What is happening near me?';
    if (lead != null) {
      final title = lead.title!.trim().split(',').first.trim();
      if (title.isNotEmpty) {
        first =
            'What should I do about the '
            '${title[0].toLowerCase()}${title.substring(1)}?';
      }
    }
    return [
      first,
      'What does Emergency Warning mean?',
      'What is my local emergency number?',
    ];
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

    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final maxSheetHeight = (media.size.height * 0.88 - bottomInset)
        .clamp(media.size.height * 0.4, media.size.height * 0.88)
        .toDouble();
    final hasThread = state.messages.isNotEmpty || state.isSending;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.spMin),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            16.spMin,
            10.spMin,
            16.spMin,
            (bottomInset > 0 ? 8.spMin : media.padding.bottom + 8.spMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDragHandle(),
              SizedBox(height: 14.spMin),
              _buildHeader(state),
              if (state.dailyLimit != null) ...[
                SizedBox(height: 10.spMin),
                Text(
                  '${_isFree(state) ? 'ALRT + gives you 10 a day. ' : ''}'
                  'Library and emergency-number answers are always free.',
                  style: TextStyle(fontSize: 13.spMin, color: _muted),
                ),
              ],
              SizedBox(height: 14.spMin),
              if (hasThread)
                Flexible(child: _buildThread(state))
              else
                _buildSuggestionChips(),
              if (state.limitReached && _isFree(state)) ...[
                SizedBox(height: 12.spMin),
                _buildUpgradePrompt(context),
              ],
              SizedBox(height: 14.spMin),
              _buildInputRow(state),
              SizedBox(height: 14.spMin),
              _buildDangerNote(),
              SizedBox(height: 4.spMin),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.spMin,
        height: 4.spMin,
        decoration: BoxDecoration(
          color: _fieldBorder,
          borderRadius: BorderRadius.circular(2.spMin),
        ),
      ),
    );
  }

  Widget _buildHeader(final AskAlrtProviderState state) {
    final pill = _quotaPill(state);
    final empty = state.remainingToday == 0 && _isFree(state);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.spMin,
          height: 44.spMin,
          decoration: BoxDecoration(
            gradient: _askAlrtGradient,
            borderRadius: BorderRadius.circular(14.spMin),
          ),
          child: Icon(
            LucideIcons.sparkles,
            size: 22.spMin,
            color: AppColors.white,
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
                  fontSize: 22.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: _ink,
                ),
              ),
              SizedBox(height: 2.spMin),
              Text(
                'Plain answers, grounded in the official alerts near you.',
                style: TextStyle(
                  fontSize: 14.spMin,
                  color: _muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (pill != null) ...[
          SizedBox(width: 8.spMin),
          Container(
            height: 26.spMin,
            padding: EdgeInsets.symmetric(horizontal: 10.spMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: empty ? const Color(0xFFFDE8EA) : _questionTint,
              borderRadius: BorderRadius.circular(13.spMin),
            ),
            child: Text(
              pill,
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w700,
                color: empty ? const Color(0xFFB3141F) : AppColors.sectionLabel,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionChips() {
    final questions = _suggestions();
    return Wrap(
      spacing: 8.spMin,
      runSpacing: 8.spMin,
      children: [
        for (final question in questions)
          InkWell(
            onTap: () => _send(question),
            borderRadius: BorderRadius.circular(20.spMin),
            child: Container(
              constraints: BoxConstraints(minHeight: 40.spMin),
              padding: EdgeInsets.symmetric(
                horizontal: 16.spMin,
                vertical: 8.spMin,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: _fieldBorder, width: 1.5),
                borderRadius: BorderRadius.circular(20.spMin),
              ),
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThread(final AskAlrtProviderState state) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: state.messages.length + (state.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return const _ThinkingBubble();
        }
        return _MessageBubble(message: state.messages[index]);
      },
    );
  }

  /// Offered once, under the answers, when ALRT Free's daily questions are
  /// used up.
  Widget _buildUpgradePrompt(final BuildContext context) {
    return SizedBox(
      height: 48.spMin,
      child: FilledButton(
        onPressed: () => context
            .push<bool>(
              AlrtPlusPaywallScreen.route,
              extra: const AlrtPlusPaywallArgs(
                reason: AlrtPlusPaywallReason.askLimit,
              ),
            )
            .then((_) {
              if (!mounted) return;
              ref.read(providerOfAskAlrt.notifier).refreshAllowance();
            }),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF7B359A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        child: Text(
          'See ALRT + for 10 questions a day',
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildInputRow(final AskAlrtProviderState state) {
    final hasThread = state.messages.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _inputController,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: _send,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.white,
              hintText: hasThread
                  ? 'Ask something else'
                  : 'What does this warning mean for me?',
              hintStyle: TextStyle(
                fontSize: 15.spMin,
                color: _muted.withValues(alpha: 0.7),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.spMin,
                vertical: 14.spMin,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.spMin),
                borderSide: const BorderSide(color: _fieldBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.spMin),
                borderSide: const BorderSide(color: _brandOrange, width: 1.5),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.spMin),
        SizedBox(
          height: 48.spMin,
          child: FilledButton(
            onPressed: state.isSending
                ? null
                : () => _send(_inputController.text),
            style: FilledButton.styleFrom(
              backgroundColor: _brandOrange,
              disabledBackgroundColor: _brandOrange.withValues(alpha: 0.5),
              padding: EdgeInsets.symmetric(horizontal: 18.spMin),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.spMin),
              ),
            ),
            child: Text(
              'Ask',
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerNote() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: _noteTint,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        "If you're in immediate danger, call your local emergency number now. "
        'ALRT is information, not emergency services.',
        style: TextStyle(fontSize: 13.spMin, color: _noteText, height: 1.45),
      ),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      height: 44.spMin,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(foregroundColor: _muted),
        child: Text(
          'Close',
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// One message: the question in a soft orange bubble on the right, the
/// answer in a white card on the left with a line saying where it came from
/// and whether it counted.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AskAlrtMessage message;

  /// Local fallback bubbles (limit, unavailable, rate limited) are not
  /// answers, so they carry no source line.
  bool get _isNotice =>
      message.text == AskAlrtProvider.limitAnswer ||
      message.text == AskAlrtProvider.unavailableAnswer ||
      message.text == AskAlrtProvider.tooManyRequestsAnswer;

  String? get _sourceLine {
    if (_isNotice) return null;
    if (message.freeAnswer) return 'From the ALRT library. Not counted.';
    final agencies = <String>[];
    for (final alert in message.groundingAlerts) {
      final name = (alert.source?.name ?? '').trim();
      final label = name.isEmpty ? 'official source' : name;
      if (!agencies.contains(label)) agencies.add(label);
    }
    if (agencies.isNotEmpty) {
      return 'Based on ${agencies.join(' and ')}. Counted.';
    }
    return "AI answer, counted against today's questions";
  }

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
            color: _questionTint,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.spMin),
              topRight: Radius.circular(16.spMin),
              bottomLeft: Radius.circular(16.spMin),
              bottomRight: Radius.circular(4.spMin),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(fontSize: 15.spMin, color: _ink, height: 1.4),
          ),
        ),
      );
    }

    final source = _sourceLine;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 10.spMin, right: 24.spMin),
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.spMin),
            topRight: Radius.circular(16.spMin),
            bottomLeft: Radius.circular(4.spMin),
            bottomRight: Radius.circular(16.spMin),
          ),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.04)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 3.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(fontSize: 15.spMin, color: _ink, height: 1.5),
            ),
            if (source != null) ...[
              SizedBox(height: 8.spMin),
              Text(
                source,
                style: TextStyle(fontSize: 12.spMin, color: _muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A quiet "thinking" indicator while the answer is on its way.
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 10.spMin),
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 14.spMin),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.06)),
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
    );
  }

  Widget _buildDot(final int index) {
    final phase = (_controller.value + index / 3) % 1;
    final wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
    return Opacity(
      opacity: 0.25 + 0.75 * wave,
      child: Container(
        width: 6.spMin,
        height: 6.spMin,
        decoration: const BoxDecoration(
          color: _muted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
