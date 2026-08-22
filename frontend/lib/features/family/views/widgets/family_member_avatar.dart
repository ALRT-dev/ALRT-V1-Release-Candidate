import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';

/// Circular member avatar with initials (or profile photo) in a stable
/// per-member color, plus an optional status dot.
class FamilyMemberAvatar extends StatelessWidget {
  const FamilyMemberAvatar({
    super.key,
    required this.member,
    this.size = 44.0,
    this.showStatusDot = true,
    this.isNearAlert = false,
  });

  final FamilyMember member;
  final double size;
  final bool showStatusDot;

  /// Ambers the status dot when the member is near an active alert.
  final bool isNearAlert;

  /// Parses "#RRGGBB"; falls back to the stable per-member palette.
  Color _memberColor() {
    final hex = member.colorHex;
    if (hex != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
      return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
    }
    return FamilyColors.memberColor(member.id);
  }

  @override
  Widget build(BuildContext context) {
    final color = _memberColor();
    final photoUrl = member.profilePictureUrl;

    final avatar = Container(
      width: size.spMin,
      height: size.spMin,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // The chosen colour stays visible as a ring around the photo.
        border: photoUrl != null && photoUrl.isNotEmpty
            ? Border.all(color: color, width: 2)
            : null,
        image: photoUrl != null && photoUrl.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(photoUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              member.initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: (size * 0.36).spMin,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    if (!showStatusDot) return avatar;

    final dotColor = isNearAlert
        ? FamilyColors.amber
        : member.isCheckedInRecently
            ? FamilyColors.safeGreen
            : Colors.grey.shade400;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: (size * 0.28).spMin,
            height: (size * 0.28).spMin,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
