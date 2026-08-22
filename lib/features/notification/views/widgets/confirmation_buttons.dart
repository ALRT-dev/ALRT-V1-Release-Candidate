import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/others/app_colors.dart';

class ConfirmationButtons extends ConsumerStatefulWidget {
  const ConfirmationButtons({
    super.key,
    required this.initialVoteCount,
    this.updateOnPressed = true,
    this.initialVoteType,
    this.onVotePressed,
  });

  /// The total number of votes for the hazard.
  final int initialVoteCount;

  /// Whether the confirmation buttons should update its state when pressed.
  final bool updateOnPressed;

  /// The type of vote (upvote or downvote) that the user has made.
  final HazardVoteType? initialVoteType;

  /// Callback when the user presses the vote buttons.
  final Function(HazardVoteType)? onVotePressed;

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
    return Container(
      height: 40.spMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.spMin),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1.0,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Not There button
          Expanded(
            child: GestureDetector(
              onTap: _handleDownvote,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.spMin),
                    bottomLeft: Radius.circular(10.spMin),
                  ),

                  color: _voteType == HazardVoteType.downvote
                      ? Colors.red
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6.spMin,
                  children: [
                    Icon(
                      Icons.thumb_down_outlined,
                      size: 16.spMin,
                      color: _voteType == HazardVoteType.downvote
                          ? AppColors.white
                          : AppColors.grey,
                    ),
                    Text(
                      'Not There',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w600,
                        color: _voteType == HazardVoteType.downvote
                            ? AppColors.white
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: 1.0,
            height: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8.spMin),
            color: AppColors.lightGrey,
          ),

          // Confirm button
          Expanded(
            child: GestureDetector(
              onTap: _handleUpvote,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.spMin),
                    bottomRight: Radius.circular(10.spMin),
                  ),
                  color: _voteType == HazardVoteType.upvote
                      ? Colors.green
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6.spMin,
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16.spMin,
                      color: _voteType == HazardVoteType.upvote
                          ? AppColors.white
                          : AppColors.grey,
                    ),
                    Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w600,
                        color: _voteType == HazardVoteType.upvote
                            ? AppColors.white
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
