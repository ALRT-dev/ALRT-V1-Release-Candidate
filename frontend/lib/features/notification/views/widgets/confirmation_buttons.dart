import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The one wording for community confirmation, used by the feed card and
/// the detail screen alike: the V3 section label and the helper line that
/// says who may answer and that the answer is anonymous.
class ConfirmationPrompt extends StatelessWidget {
  const ConfirmationPrompt({super.key});

  static const String label = 'CAN YOU SEE IT?';
  static const String helper =
      'Only people nearby can respond. Your answer is anonymous.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.sectionLabel,
          ),
        ),
        SizedBox(height: 4.spMin),
        Text(
          helper,
          style: TextStyle(
            fontSize: 13.spMin,
            height: 1.35,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

/// "I see it" / "I don't see it" buttons plus the count line under them.
/// Text only, no thumbs: the words carry the meaning.
class ConfirmationButtons extends ConsumerStatefulWidget {
  const ConfirmationButtons({
    super.key,
    required this.initialVoteCount,
    this.updateOnPressed = true,
    this.initialVoteType,
    this.onVotePressed,
    this.showVoteCount = true,
  });

  /// The total number of votes for the hazard.
  final int initialVoteCount;

  /// Whether the confirmation buttons should update its state when pressed.
  final bool updateOnPressed;

  /// The type of vote (upvote or downvote) that the user has made.
  final HazardVoteType? initialVoteType;

  /// Callback when the user presses the vote buttons.
  final Function(HazardVoteType)? onVotePressed;

  /// Whether to show the "N people confirmed" line under the buttons.
  final bool showVoteCount;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConfirmationButtonsState();
}

class _ConfirmationButtonsState extends ConsumerState<ConfirmationButtons> {
  HazardVoteType? _voteType;

  @override
  void didUpdateWidget(covariant ConfirmationButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialVoteType != widget.initialVoteType) {
      _voteType = widget.initialVoteType;
    }
  }

  @override
  void initState() {
    super.initState();
    _voteType = widget.initialVoteType;
  }

  @override
  Widget build(BuildContext context) {
    final isUpvoted = _voteType == HazardVoteType.upvote;
    final isDownvoted = _voteType == HazardVoteType.downvote;
    final count = widget.initialVoteCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // I see it: the primary, solid green (the colour the detail
            // screen has always used for the positive answer).
            Expanded(
              child: _buttonBuilder(
                label: 'I see it',
                onTap: _handleUpvote,
                background: isUpvoted ? AppColors.darkGreen : AppColors.green,
                foreground: AppColors.white,
                borderColor: isUpvoted ? AppColors.darkGreen : AppColors.green,
                leading: isUpvoted ? LucideIcons.check : null,
              ),
            ),
            SizedBox(width: 10.spMin),
            // I don't see it: outlined white, 1 px #E3E6EA.
            Expanded(
              child: _buttonBuilder(
                label: "I don't see it",
                onTap: _handleDownvote,
                background: isDownvoted ? AppColors.red : AppColors.white,
                foreground: isDownvoted ? AppColors.white : AppColors.ink,
                borderColor: isDownvoted ? AppColors.red : AppColors.lightGrey,
                leading: isDownvoted ? LucideIcons.check : null,
              ),
            ),
          ],
        ),
        if (widget.showVoteCount && count != 0) ...[
          SizedBox(height: 8.spMin),
          Text(
            count > 0
                ? '${count.abs()} ${count.abs() == 1 ? 'person' : 'people'} confirmed'
                : "${count.abs()} ${count.abs() == 1 ? 'person' : 'people'} don't see it",
            style: TextStyle(
              fontSize: 12.spMin,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buttonBuilder({
    required final String label,
    required final VoidCallback onTap,
    required final Color background,
    required final Color foreground,
    required final Color borderColor,
    final IconData? leading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44.spMin,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 16.spMin, color: foreground),
              SizedBox(width: 6.spMin),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpvote() {
    if (widget.updateOnPressed) {
      setState(() {
        if (_voteType == HazardVoteType.upvote) {
          // Remove upvote
          _voteType = null;
        } else {
          // Add upvote
          _voteType = HazardVoteType.upvote;
        }
      });
    }

    widget.onVotePressed?.call(HazardVoteType.upvote);
  }

  void _handleDownvote() {
    if (widget.updateOnPressed) {
      setState(() {
        if (_voteType == HazardVoteType.downvote) {
          // Remove downvote
          _voteType = null;
        } else {
          // Add downvote
          _voteType = HazardVoteType.downvote;
        }
      });
    }

    widget.onVotePressed?.call(HazardVoteType.downvote);
  }
}
