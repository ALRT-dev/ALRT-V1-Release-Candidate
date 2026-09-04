import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The Family invite flow: generate a code, show it as text and as a QR,
/// copy or send it, see what is still active, revoke it.
///
/// This is deliberately a different thing from Profile's "Share ALRT"
/// (share_alrt_sheet.dart), which only tells someone about the app. A
/// Family invite is a code for one specific circle, redeemed inside the
/// app under Family → "I have an invite code". Nothing here links to the
/// website or a store: the code is the whole payload, so it works the same
/// on a TEST build (sideloaded APK) as it will on a store build, and a
/// scanned QR simply shows the code to type. Joining with a code is always
/// free; only the host's plan is involved (see the seat rule in
/// family.service.ts).
class FamilyInviteScreen extends ConsumerStatefulWidget {
  const FamilyInviteScreen({super.key});

  static const route = '/family-invite';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyInviteScreenState();
}

class _FamilyInviteScreenState extends ConsumerState<FamilyInviteScreen> {
  /// The code the big card and QR currently show: the one just generated,
  /// or an active one the owner tapped in the list.
  String? _shownCode;

  /// When on, the next generated code makes whoever redeems it a guest.
  bool _inviteAsGuest = false;

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
      'Join my family circle on ALRT with code $code — in the app, open '
      'Family, tap "I have an invite code" and enter it. Joining is free.';

  @override
  Widget build(BuildContext context) {
    final invites = ref.watch(providerOfFamily.select((s) => s.invites));
    final createState = ref.watch(
      providerOfFamily.select((s) => s.createInviteState),
    );
    final circleName = ref.watch(
      providerOfFamily.select((s) => s.circle?.name ?? 'your circle'),
    );

    // Keep showing a code only while it is still active (revoked or
    // expired codes drop out of `invites`, and so out of the big card).
    final shown = _shownCode != null &&
            invites.any((invite) => invite.code == _shownCode)
        ? _shownCode
        : null;

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: FamilyAppBar(
        title: 'Add a member',
        subtitle: 'Invite someone to $circleName',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (shown != null) ...[
              _codeCardBuilder(shown),
              SizedBox(height: 14.spMin),
            ],
            SizedBox(
              height: 50.spMin,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: createState.isLoading ? null : _onGenerate,
                icon: Icon(
                  shown == null ? LucideIcons.userPlus : LucideIcons.ticket,
                  size: 18.spMin,
                ),
                label: Text(
                  createState.isLoading
                      ? 'Generating...'
                      : shown == null
                          ? 'Create an invite code'
                          : 'Create another code',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Codes can be used up to 10 times and expire after 7 days. '
              'Revoke one at any time below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
            ),
            SizedBox(height: 14.spMin),
            _guestToggleBuilder(),
            SizedBox(height: 14.spMin),
            _howTheyJoinBuilder(),
            SizedBox(height: 24.spMin),
            if (invites.isNotEmpty) ...[
              Text(
                'ACTIVE INVITES · ${invites.length}',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: FamilyColors.v31Label,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 10.spMin),
              ...invites.map((invite) => _inviteTileBuilder(invite, shown)),
            ],
          ],
        ),
      ),
    );
  }

  /// Guest invites cost the owner nothing, so the explainer says exactly
  /// what a guest can and cannot do before the code is minted.
  Widget _guestToggleBuilder() {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(
          color: _inviteAsGuest
              ? FamilyColors.indigo
              : const Color(0xFFE6E6EA),
          width: _inviteAsGuest ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.userRound,
                size: 18.spMin,
                color: FamilyColors.indigo,
              ),
              SizedBox(width: 10.spMin),
              Expanded(
                child: Text(
                  'Invite as a guest',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: _inviteAsGuest,
                activeTrackColor: FamilyColors.indigo,
                onChanged: (value) => setState(() => _inviteAsGuest = value),
              ),
            ],
          ),
          SizedBox(height: 4.spMin),
          Text(
            'A guest receives your circle\'s alerts and can say "I\'m Safe". '
            'They never request anyone\'s location, and they use none of '
            'your seats. A full member uses one of your seats; you never '
            'use one yourself.',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.4,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// The redeem path, stated on the screen the host is looking at, so they
  /// can talk the other person through it.
  Widget _howTheyJoinBuilder() {
    Widget step(final int n, final String text) => Padding(
          padding: EdgeInsets.only(bottom: 6.spMin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20.spMin,
                height: 20.spMin,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: FamilyColors.indigoLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w800,
                    color: FamilyColors.indigoDark,
                  ),
                ),
              ),
              SizedBox(width: 10.spMin),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    height: 1.4,
                    color: FamilyColors.v31Ink,
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW THEY JOIN',
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: FamilyColors.v31Label,
            ),
          ),
          SizedBox(height: 10.spMin),
          step(1, 'They open ALRT on their own phone and go to Family.'),
          step(2, 'They tap "I have an invite code".'),
          step(
            3,
            'They enter the code (or read it off your QR). No website, '
            'no link - the code is all they need.',
          ),
        ],
      ),
    );
  }

  Widget _codeCardBuilder(final String code) {
    return Container(
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(20.spMin),
        border: Border.all(color: FamilyColors.indigo.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Show this to the person you are inviting',
            style: TextStyle(fontSize: 13.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 14.spMin),
          Container(
            padding: EdgeInsets.all(12.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.spMin),
            ),
            // The QR encodes the bare code - scanning it with a phone
            // camera shows the code to type; there is no website or store
            // link behind it.
            child: QrImageView(
              data: code,
              size: 172.spMin,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: FamilyColors.indigoDark,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: FamilyColors.indigoDark,
              ),
            ),
          ),
          SizedBox(height: 12.spMin),
          SelectableText(
            code,
            style: TextStyle(
              fontSize: 30.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: FamilyColors.indigoDark,
            ),
          ),
          SizedBox(height: 12.spMin),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FamilyColors.indigo,
                    side: const BorderSide(color: FamilyColors.indigo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                  ),
                  onPressed: () => _copyCode(code),
                  icon: Icon(LucideIcons.copy, size: 16.spMin),
                  label: const Text('Copy code'),
                ),
              ),
              SizedBox(width: 10.spMin),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FamilyColors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                  ),
                  onPressed: () => _shareCode(code),
                  icon: Icon(LucideIcons.send, size: 16.spMin),
                  label: const Text('Send code'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inviteTileBuilder(final FamilyInvite invite, final String? shown) {
    final isShown = invite.code == shown;
    return Container(
      margin: EdgeInsets.only(bottom: 8.spMin),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: isShown
            ? Border.all(color: FamilyColors.indigo.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _shownCode = invite.code),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        invite.code,
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (invite.isGuestInvite) ...[
                        SizedBox(width: 8.spMin),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.spMin,
                            vertical: 2.spMin,
                          ),
                          decoration: BoxDecoration(
                            color: FamilyColors.indigoLight,
                            borderRadius: BorderRadius.circular(8.spMin),
                          ),
                          child: Text(
                            'GUEST',
                            style: TextStyle(
                              fontSize: 9.5.spMin,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: FamilyColors.indigoDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Used ${invite.useCount} of ${invite.maxUses}'
                    '${invite.expiresAt != null ? ' · expires ${timeago.format(invite.expiresAt!, allowFromNow: true)}' : ''}'
                    '${isShown ? '' : ' · tap for QR'}',
                    style: TextStyle(fontSize: 11.spMin, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy code',
            icon: Icon(LucideIcons.copy, size: 18.spMin, color: AppColors.grey),
            onPressed: () => _copyCode(invite.code),
          ),
          IconButton(
            tooltip: 'Revoke',
            icon: Icon(LucideIcons.trash2, size: 18.spMin, color: Colors.red),
            onPressed: () => _confirmRevoke(invite),
          ),
        ],
      ),
    );
  }

  void _onGenerate() async {
    final invite = await ref
        .read(providerOfFamily.notifier)
        .createInvite(isGuestInvite: _inviteAsGuest);
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
        subject: 'Your ALRT family invite code',
      ),
    );
  }

  void _confirmRevoke(final FamilyInvite invite) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke this invite?'),
        content: Text(
          'Code ${invite.code} stops working immediately. People who '
          'already joined with it stay in the circle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref
                  .read(providerOfFamily.notifier)
                  .revokeInvite(inviteId: invite.id);
              if (_shownCode == invite.code) {
                setState(() => _shownCode = null);
              }
            },
            child: const Text(
              'Revoke',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
