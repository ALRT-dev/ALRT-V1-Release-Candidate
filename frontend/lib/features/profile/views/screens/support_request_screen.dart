import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/providers/states/support_request_provider_state.dart';
import 'package:hazard_app/features/profile/providers/support_request_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/enums/support_request_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Help and feedback", as on the prototype "Support" board: white header,
/// one row of type chips (Support, Feedback, Question, Other), a "What
/// happened?" box, the orange "Submit request" button, and once sent a
/// "Request submitted" card ("We reply by email."). Sends through the
/// existing support request provider (POST /support).
class SupportRequestScreen extends ConsumerStatefulWidget {
  const SupportRequestScreen({super.key});

  static const route = '/support-request';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SupportRequestScreenState();
}

class _SupportRequestScreenState extends ConsumerState<SupportRequestScreen> {
  final _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listenToSubmitStateChanges();

    final state = ref.watch(providerOfSupportRequest);
    final isLoading = state.submitState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final isSent = state.submitState.maybeWhen(
      success: () => true,
      orElse: () => false,
    );
    final selected = state.requestType ?? SupportRequestType.support;

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            const ProfilePageHeader(title: 'Help and feedback'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16.spMin,
                  14.spMin,
                  16.spMin,
                  32.spMin,
                ),
                children: [
                  Wrap(
                    spacing: 8.spMin,
                    runSpacing: 8.spMin,
                    children: [
                      for (final type in SupportRequestType.values)
                        _TypeChip(
                          label: _label(type),
                          selected: selected == type,
                          onTap: () => ref
                              .read(providerOfSupportRequest.notifier)
                              .updateRequestType(type),
                        ),
                    ],
                  ),
                  SizedBox(height: 14.spMin),
                  SizedBox(
                    height: 110.spMin,
                    child: TextField(
                      key: const Key('support-details'),
                      controller: _detailsController,
                      enabled: !isLoading,
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => ref
                          .read(providerOfSupportRequest.notifier)
                          .updateDetails(value.trim()),
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What happened?',
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.all(12.spMin),
                        enabledBorder: _border(ProfilePageKit.hairline),
                        disabledBorder: _border(ProfilePageKit.hairline),
                        focusedBorder: _border(AppColors.orange),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.spMin),
                  ProfileButton(
                    key: const Key('support-send'),
                    label: 'Submit request',
                    busy: isLoading,
                    onPressed: state.details.isEmpty ? null : _submit,
                  ),
                  if (isSent) ...[
                    SizedBox(height: 14.spMin),
                    ProfileCard(
                      children: [
                        Text(
                          'Request submitted',
                          style: TextStyle(
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const ProfileMutedText('We reply by email.'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _border(final Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.spMin),
        borderSide: BorderSide(color: color, width: 1.5),
      );

  String _label(final SupportRequestType type) => switch (type) {
        SupportRequestType.support => 'Support',
        SupportRequestType.feedback => 'Feedback',
        SupportRequestType.question => 'Question',
        SupportRequestType.other => 'Other',
      };

  void _onInit() {
    final notifier = ref.read(providerOfSupportRequest.notifier);
    notifier.updateRequestSubmitted(false);
    notifier.resetAllFields();
    notifier.updateRequestType(SupportRequestType.support);
  }

  /// Shows a toast when sending fails.
  void _listenToSubmitStateChanges() {
    ref.listen(
      providerOfSupportRequest.select((value) => value.submitState),
      (previous, next) {
        if (previous == next) return;
        next.maybeWhen(
          error: (error) => context.showErrorToast(
            message: error.message.isNotEmpty
                ? error.message
                : 'Your request could not be sent. Try again.',
          ),
          orElse: () {},
        );
      },
    );
  }

  /// Sends, then clears the box and keeps the chosen type for another.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(providerOfSupportRequest.notifier);
    final type = ref.read(providerOfSupportRequest).requestType ??
        SupportRequestType.support;
    notifier.updateRequestType(type);
    await notifier.submitSupportRequest();
    if (!mounted) return;
    final sent = ref.read(providerOfSupportRequest).submitState.maybeWhen(
          success: () => true,
          orElse: () => false,
        );
    if (sent) {
      _detailsController.clear();
      notifier.updateDetails('');
    }
  }
}

/// The prototype chip: 40 px pill, ink border and bold when selected.
class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40.spMin,
        padding: EdgeInsets.symmetric(horizontal: 16.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFAF9F7) : AppColors.white,
          borderRadius: BorderRadius.circular(20.spMin),
          border: Border.all(
            color: selected ? AppColors.ink : ProfilePageKit.hairline,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
