import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';

/// The Leave sheet (LeaveSheet board): "Leave <group>?", what you keep and
/// that nobody is told, the host's 7 day hand-over when you host it, then
/// "Leave circle" and "Stay". Returns true when the person chose to leave.
///
/// [isHost] defaults to whether you host the group being viewed.
/// [sosListCount] is accepted for existing callers; the board's copy does
/// not list SOS lists.
Future<bool> showFamilyLeaveConfirmSheet({
  required final BuildContext context,
  required final String circleName,
  final int sosListCount = 0,
  final bool? isHost,
}) async {
  final left = await showFamilyBoardSheet<bool>(
    context: context,
    builder: (sheetContext) => [
      Consumer(
        builder: (context, ref, _) {
          final myRole = ref.watch(
            providerOfFamily.select((s) => s.circle?.me?.role),
          );
          final hosting = isHost ?? (myRole == FamilyRole.owner);
          return FamilyBoardSheetTitle(
            'Leave $circleName?',
            subtitle: hosting
                ? 'You keep your own alerts, map and guidance. No '
                      'announcement is sent. You host this circle: members '
                      'get 7 days to choose a new host.'
                : 'You keep your own alerts, map and guidance. No '
                      'announcement is sent.',
          );
        },
      ),
      FamilyBoardPrimaryButton(
        key: const Key('leave-go'),
        label: 'Leave circle',
        onPressed: () => Navigator.of(sheetContext).pop(true),
      ),
      FamilyBoardGhostButton(
        label: 'Stay',
        onPressed: () => Navigator.of(sheetContext).pop(false),
      ),
    ],
  );
  return left ?? false;
}
