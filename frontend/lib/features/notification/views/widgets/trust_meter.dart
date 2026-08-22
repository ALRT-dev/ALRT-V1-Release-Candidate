import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/others/app_colors.dart';

class TrustMeter extends ConsumerStatefulWidget {
  const TrustMeter({
    super.key,
    required this.initialVoteCount,
    this.updateOnPressed = true,
    this.initialVoteType,
    this.onVotePressed,
  });

  /// The total number of votes for the hazard.
  final int initialVoteCount;

  /// Whether the trust meter should update its state when pressed.
  final bool updateOnPressed;

  /// The type of vote (upvote or downvote) that the user has made.
  final HazardVoteType? initialVoteType;

  /// Callback when the user presses the vote buttons.
  final Function(HazardVoteType)? onVotePressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrustMeterState();
}

class _TrustMeterState extends ConsumerState<TrustMeter> {
  HazardVoteType? _voteType;
  var _voteCount = 0;

  @override
  void didUpdateWidget(covariant TrustMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialVoteCount != widget.initialVoteCount) {
      _voteCount = widget.initialVoteCount;
    }
    if (oldWidget.initialVoteType != widget.initialVoteType) {
      _voteType = widget.initialVoteType;
    }
  }

  @override
  void initState() {
    super.initState();
    _voteType = widget.initialVoteType;
    _voteCount = widget.initialVoteCount;
  }

  @override
  Widget build(BuildContext context) {
    final authenticity = _calculateAuthenticity();
    final authenticityColor = _getAuthenticityColor(authenticity);

    return Container(
      height: 40.spMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
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
        spacing: 3.spMin,
        children: [
          // Downvote zone
          GestureDetector(
            onTap: _handleDownvote,
            child: Container(
              width: 50.spMin,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                ),
                color: _voteType == HazardVoteType.downvote
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: Center(
                child: Icon(
                  Icons.thumb_down_outlined,
                  size: 16.spMin,
                  color: _voteType == HazardVoteType.downvote
                      ? Colors.red
                      : AppColors.grey,
                ),
              ),
            ),
          ),

          // Trust meter center
          Expanded(
            child: SizedBox(
              height: double.infinity,
              child: Stack(
                children: [
                  // Background track
                  Container(
                    height: 14.spMin,
                    margin: EdgeInsets.symmetric(vertical: 11.spMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.r),
                      color: AppColors.grey.withValues(alpha: 0.1),
                    ),
                  ),

                  // Progress fill
                  Container(
                    height: 14.spMin,
                    margin: EdgeInsets.symmetric(vertical: 11.spMin),
                    child: FractionallySizedBox(
                      widthFactor: authenticity,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.r),
                          gradient: LinearGradient(
                            colors: [
                              authenticityColor.withValues(alpha: 0.6),
                              authenticityColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vote count and label
                  Center(
                    child: Text(
                      _formatVoteCount(_voteCount),
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Upvote zone
          GestureDetector(
            onTap: _handleUpvote,
            child: Container(
              width: 50.spMin,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                color: _voteType == HazardVoteType.upvote
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: Center(
                child: Icon(
                  Icons.thumb_up_outlined,
                  size: 16.spMin,
                  color: _voteType == HazardVoteType.upvote
                      ? Colors.green
                      : AppColors.grey,
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
          _voteCount--;
        } else {
          // Add upvote
          _voteType = HazardVoteType.upvote;
          _voteCount++;

          // Remove downvote if it was active
          if (_voteType == HazardVoteType.downvote) {
            _voteType = HazardVoteType.upvote;

            // Add two because we're removing a downvote and adding an upvote
            _voteCount += 2;
          }
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
          _voteCount++;
        } else {
          // Add downvote
          _voteType = HazardVoteType.downvote;
          _voteCount--;

          // Remove upvote if it was active
          if (_voteType == HazardVoteType.upvote) {
            _voteType = HazardVoteType.downvote;

            // Subtract two because we're removing an upvote and adding a downvote
            _voteCount -= 2;
          }
        }
      });
    }

    widget.onVotePressed?.call(HazardVoteType.downvote);
  }

  String _formatVoteCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  double _calculateAuthenticity() {
    // Calculate meter position based on vote count
    // 0 votes = 0.5 (center)
    // Positive votes = move right (0.5 to 1.0)
    // Negative votes = move left (0.0 to 0.5)

    const maxVotes = 20; // Max votes to reach the ends of the meter

    if (_voteCount == 0) {
      return 0.5; // Center position
    } else if (_voteCount > 0) {
      // Positive votes: map from 0.5 to 1.0
      final progress = (_voteCount / maxVotes).clamp(0.0, 1.0);
      return 0.5 + (progress * 0.5);
    } else {
      // Negative votes: map from 0.0 to 0.5
      final progress = (_voteCount.abs() / maxVotes).clamp(0.0, 1.0);
      return 0.5 - (progress * 0.5);
    }
  }

  Color _getAuthenticityColor(double authenticity) {
    // Color based on meter position
    // Left side (0.0-0.5): Red to Yellow gradient
    // Right side (0.5-1.0): Yellow to Green gradient

    if (authenticity < 0.5) {
      // Negative votes: Red to Yellow
      final progress = authenticity * 2; // Map 0.0-0.5 to 0.0-1.0
      return Color.lerp(Colors.red, Colors.orange, progress)!;
    } else if (authenticity > 0.5) {
      // Positive votes: Yellow to Green
      final progress = (authenticity - 0.5) * 2; // Map 0.5-1.0 to 0.0-1.0
      return Color.lerp(Colors.orange, Colors.green, progress)!;
    } else {
      // Exactly at center (0 votes)
      return Colors.orange;
    }
  }
}
