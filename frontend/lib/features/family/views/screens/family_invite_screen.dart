import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Generate and manage invite codes for the family circle.
class FamilyInviteScreen extends ConsumerStatefulWidget {
  const FamilyInviteScreen({super.key});

  static const route = '/family-invite';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyInviteScreenState();
}

class _FamilyInviteScreenState extends ConsumerState<FamilyInviteScreen> {
  String? _latestCode;

  /// When on, the next generated code makes whoever redeems it a guest.
  bool _inviteAsGuest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(providerOfFamily.notifier).loadInvites(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invites = ref.watch(providerOfFamily.select((s) => s.invites));
    final createState = ref.watch(
      providerOfFamily.select((s) => s.createInviteState),
    );

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: const FamilyAppBar(title: 'Invite members'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_latestCode != null) _codeCardBuilder(_latestCode!),
            SizedBox(height: 14.spMin),
            SizedBox(
              height: 50.spMin,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: createState.isLoading ? null : _onGenerate,
                icon: Icon(LucideIcons.ticket, size: 18.spMin),
                label: Text(
                  createState.isLoading
                      ? 'Generating...'
                      : 'Generate invite code',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Codes can be used up to 10 times and expire after 7 days.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
            ),
            SizedBox(height: 14.spMin),
            _guestToggleBuilder(),
            SizedBox(height: 24.spMin),
            if (invites.isNotEmpty) ...[
              Text(
                'ACTIVE INVITES',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: FamilyColors.v31Label,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 10.spMin),
              ...invites.map(_inviteTileBuilder),
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
                LucideIcons.userPlus,
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
            'your seats.',
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
            'Share this code with your family',
            style: TextStyle(fontSize: 13.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 10.spMin),
          Text(
            code,
            style: TextStyle(
              fontSize: 30.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: FamilyColors.indigoDark,
            ),
          ),
          SizedBox(height: 12.spMin),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: FamilyColors.indigo,
              side: const BorderSide(color: FamilyColors.indigo),
            ),
            onPressed: () => _copyCode(code),
            icon: Icon(LucideIcons.copy, size: 16.spMin),
            label: const Text('Copy code'),
          ),
        ],
      ),
    );
  }

  Widget _inviteTileBuilder(final invite) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.spMin),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.code,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Used ${invite.useCount} of ${invite.maxUses}'
                  '${invite.expiresAt != null ? ' · expires ${timeago.format(invite.expiresAt!, allowFromNow: true)}' : ''}',
                  style: TextStyle(fontSize: 11.spMin, color: AppColors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.copy, size: 18.spMin, color: AppColors.grey),
            onPressed: () => _copyCode(invite.code),
          ),
          IconButton(
            icon: Icon(LucideIcons.trash2, size: 18.spMin, color: Colors.red),
            onPressed: () => ref
                .read(providerOfFamily.notifier)
                .revokeInvite(inviteId: invite.id),
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
    setState(() => _latestCode = invite.code);
  }

  void _copyCode(final String code) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            'Join our family circle on Safety ALRT with code $code — '
            'download the app at https://safetyalrt.com/get',
      ),
    );
    if (!mounted) return;
    context.showSuccessToast(message: 'Invite copied to clipboard');
  }
}
