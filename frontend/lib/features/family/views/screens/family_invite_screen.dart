import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// The Family invite flow (12 Oct 2026 mockup): a plain white sheet with
/// one card per active code, a solid "Create an invite code" and a QR that
/// shows on request.
///
/// This is deliberately a different thing from Profile's "Share ALRT"
/// (share_alrt_sheet.dart), which only tells someone about the app. A
/// Family invite is a code for one specific group, redeemed inside the
/// app under Family → "I have an invite code". Nothing here links to the
/// website or a store: the code is the whole payload, so it works the same
/// on a TEST build (sideloaded APK) as it will on a store build.
///
/// The QR encodes the bare invite code and nothing else. The joiner scans
/// it in-app (Family → "Scan invite QR", FamilyInviteScannerSheet) and the
/// code goes through the very same join call a typed code does; a phone
/// camera outside the app simply shows the code as text to type. Joining
/// with a code is always free (V1 access model).
class FamilyInviteScreen extends ConsumerStatefulWidget {
  const FamilyInviteScreen({super.key});

  static const route = '/family-invite';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyInviteScreenState();
}

class _FamilyInviteScreenState extends ConsumerState<FamilyInviteScreen> {
  /// The code the QR shows: the one just generated, or an active one the
  /// host tapped in the list. Falls back to the newest active code.
  String? _shownCode;

  /// "Show QR" toggles the QR under the buttons.
  bool _qrVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(providerOfFamily.notifier).loadInvites(),
    );
  }

  /// What a recipient has to do with the code, spelled out once and reused
  /// by copy and share so the two can never drift apart. No URL on purpose.
  static String _redeemInstructions(final String code) =>
      'Join my group on ALRT with code $code. In the app, open Family, '
      'tap "I have an invite code" and enter it. Joining is free.';

  @override
  Widget build(BuildContext context) {
    final invites = ref.watch(providerOfFamily.select((s) => s.invites));
    final createState = ref.watch(
      providerOfFamily.select((s) => s.createInviteState),
    );
    final isHost = ref.watch(
      providerOfFamily.select((s) => s.circle?.me?.role == FamilyRole.owner),
    );

    // Keep showing a code only while it is still active (revoked or
    // expired codes drop out of `invites`, and so out of the QR).
    final shown =
        _shownCode != null && invites.any((invite) => invite.code == _shownCode)
        ? _shownCode
        : invites.firstOrNull?.code;

    return FamilyBoardScaffold(
      title: 'Add a member',
      gap: 10,
      children: [
        const FamilyBoardNote(
          'Codes can be used up to 20 times and expire after 7 days. '
          'Joining is always free.',
        ),
        for (final invite in invites)
          _inviteCardBuilder(
            invite,
            isShown: invite.code == shown,
            isHost: isHost,
          ),
        FamilyBoardPrimaryButton(
          key: const Key('invite-create'),
          label: createState.isLoading
              ? 'Creating...'
              : 'Create an invite code',
          onPressed: createState.isLoading ? null : _onGenerate,
        ),
        FamilyBoardSecondaryButton(
          key: const Key('invite-show-qr'),
          label: _qrVisible && shown != null ? 'Hide QR' : 'Show QR',
          onPressed: shown == null
              ? null
              : () => setState(() => _qrVisible = !_qrVisible),
        ),
        if (_qrVisible && shown != null) _qrBuilder(shown),
      ],
    );
  }

  /// One active code (Invite board): the code, how far through its uses
  /// it is and when it lapses, then Share and (host only) Revoke. Tapping
  /// the code copies it and makes it the one the QR shows.
  Widget _inviteCardBuilder(
    final FamilyInvite invite, {
    required final bool isShown,
    required final bool isHost,
  }) {
    final expiresAt = invite.expiresAt;
    final expires = expiresAt == null
        ? ''
        : ' · expires ${DateFormat('d MMM yyyy').format(expiresAt.toLocal())}';

    return FamilyBoardCard(
      key: Key('invite-card-${invite.id}'),
      borderColor: isShown && _qrVisible ? AppColors.ink : null,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => _shownCode = invite.code);
                  _copyCode(invite.code);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.code,
                      style: TextStyle(
                        fontSize: 20.spMin,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    FamilyBoardMuted(
                      '${invite.useCount} of ${invite.maxUses} used$expires',
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.spMin),
            FamilyBoardSmallButton(
              label: 'Share',
              onPressed: () => _shareCode(invite.code),
            ),
            if (isHost) ...[
              SizedBox(width: 8.spMin),
              FamilyBoardSmallButton(
                key: Key('invite-revoke-${invite.id}'),
                label: 'Revoke',
                onPressed: () => _confirmRevoke(invite),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// The QR for the shown code. It encodes the bare code: the in-app
  /// scanner reads it straight into the join flow; a plain phone camera
  /// just shows the code as text. There is no website or store link.
  Widget _qrBuilder(final String code) {
    return Container(
      key: const Key('invite-qr'),
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: FamilyColors.v31Divider),
      ),
      child: Column(
        children: [
          QrImageView(
            data: code,
            size: 180.spMin,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.ink,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            code,
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'They scan this in ALRT under Family, or type the code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  void _onGenerate() async {
    // V1 access model: no seats and no guest invites. In a group covered by
    // a Family/Group plan the backend checks the plan's capacity when the
    // person joins, and says so plainly if the group is full.
    final invite = await ref.read(providerOfFamily.notifier).createInvite();
    if (!mounted || invite == null) return;
    setState(() => _shownCode = invite.code);
  }

  void _copyCode(final String code) async {
    await Clipboard.setData(ClipboardData(text: _redeemInstructions(code)));
    if (!mounted) return;
    context.showSuccessToast(message: 'Invite code copied');
  }

  Future<void> _shareCode(final String code) {
    return SharePlus.instance.share(
      ShareParams(
        text: _redeemInstructions(code),
        subject: 'Your ALRT invite code',
      ),
    );
  }

  Future<void> _confirmRevoke(final FamilyInvite invite) async {
    final revoke = await showFamilyBoardSheet<bool>(
      context: context,
      builder: (sheetContext) => [
        FamilyBoardSheetTitle(
          'Revoke ${invite.code}?',
          subtitle:
              'The code stops working straight away. People who already '
              'joined with it stay in the group.',
        ),
        FamilyBoardPrimaryButton(
          key: const Key('invite-revoke-go'),
          label: 'Revoke code',
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        FamilyBoardGhostButton(
          label: 'Keep',
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    );
    if (revoke != true || !mounted) return;
    await ref.read(providerOfFamily.notifier).revokeInvite(inviteId: invite.id);
    if (!mounted) return;
    if (_shownCode == invite.code) setState(() => _shownCode = null);
  }
}
