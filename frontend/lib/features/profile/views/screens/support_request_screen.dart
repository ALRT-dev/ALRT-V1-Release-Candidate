import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/states/support_request_provider_state.dart';
import 'package:hazard_app/features/profile/providers/support_request_provider.dart';
import 'package:hazard_app/features/shared/enums/support_request_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';
import 'package:hazard_app/others/app_colors.dart';

class SupportRequestScreen extends ConsumerStatefulWidget {
  const SupportRequestScreen({super.key});

  static const route = '/support-request';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SupportRequestScreenState();
}

class _SupportRequestScreenState extends ConsumerState<SupportRequestScreen> {
  final _detailsController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // register this provider to the lifecycle of this screen
    ref.watch(providerOfSupportRequest.select((value) => null));

    _listenToSubmitStateChanges();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Support Request',
          style: TextStyle(
            color: AppColors.black,
          ),
        ),
        foregroundColor: AppColors.black,
        actions: [
          _clearAllBuilder(),
          15.wSizedBox,
        ],
      ),
      bottomNavigationBar: _submitButtonBuilder(),
      body: Consumer(
        builder: (context, ref, child) {
          final requestSubmitted = ref.watch(
            providerOfSupportRequest.select(
              (value) => value.requestSubmitted,
            ),
          );
          return requestSubmitted ? _submittedBuilder() : _formBuilder();
        },
      ),
    ).keyboardDismisser(context);
  }

  Widget _formBuilder() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(20.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitleBuilder(
            title: 'Request Type',
            isRequired: true,
          ),
          10.hSizedBox,
          _requestTypeBuilder(),
          24.hSizedBox,
          _detailsBuilder(),
          24.hSizedBox,
        ],
      ),
    );
  }

  Widget _submittedBuilder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.green,
            size: 80.spMin,
          ),
          10.hSizedBox,
          Text(
            'Request Submitted!',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          5.hSizedBox,
          Text(
            'Your support request has been submitted. We will get back to you shortly.',
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          20.hSizedBox,
          _submitAnotherButtonBuilder(),
          10.hSizedBox,
          _closeButtonBuilder(),
        ],
      ).pX(20.0),
    );
  }

  Widget _sectionTitleBuilder({
    required final String title,
    final bool isRequired = false,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
            ),
          )
        else
          Text(
            ' (Optional)',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
            ),
          ),
      ],
    );
  }

  Widget _inputBuilder({
    required final String hintText,
    final TextEditingController? controller,
    final String? value,
    final int? maxLines,
    final int? minLines,
    final TextCapitalization textCapitalization = TextCapitalization.none,
    final TextInputType? keyboardType,
    final EdgeInsetsGeometry? contentPadding,
    final bool enabled = true,
    final VoidCallback? onPressed,
    final Function(String)? onChanged,
  }) {
    return TextFormField(
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      controller: controller ?? TextEditingController(text: value),
      style: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.normal,
        ),
        contentPadding: contentPadding,
        filled: true,
        fillColor: AppColors.white,
        disabledBorder: context.theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(
            color: AppColors.lightGrey,
          ),
        ),
      ),
      onChanged: onChanged,
    ).onPressed(onPressed);
  }

  Widget _requestTypeBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedRequestType = ref.watch(
          providerOfSupportRequest.select(
            (value) => value.requestType,
          ),
        );

        return Column(
          spacing: 12.h,
          children: SupportRequestType.values.map((type) {
            final isSelected = selectedRequestType == type;
            final typeInfo = _getRequestTypeInfo(type);

            return InkWell(
              onTap: () => _handleRequestTypeSelect(type),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.spMin),
                decoration: BoxDecoration(
                  color: isSelected
                      ? typeInfo['color'].withValues(alpha: 0.005)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? typeInfo['color']
                        : AppColors.transparent,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? typeInfo['color'].withValues(alpha: 0.1)
                          : AppColors.shadowColorLight,
                      blurRadius: 5.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.spMin,
                      height: 48.spMin,
                      decoration: BoxDecoration(
                        color: typeInfo['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        typeInfo['icon'],
                        color: typeInfo['color'],
                        size: 24.spMin,
                      ),
                    ),
                    16.wSizedBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeInfo['title'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          4.hSizedBox,
                          Text(
                            typeInfo['description'],
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.grey,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: typeInfo['color'],
                        size: 24.spMin,
                      )
                    else
                      Icon(
                        Icons.circle_outlined,
                        color: AppColors.lightGrey,
                        size: 24.spMin,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _detailsBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.h,
      children: [
        _sectionTitleBuilder(
          title: 'Details',
          isRequired: true,
        ),
        _inputBuilder(
          hintText: 'Provide details about your request...',
          controller: _detailsController,
          minLines: 8,
          maxLines: 15,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          contentPadding: EdgeInsets.all(15.spMin),
          onChanged: (value) => _updateDetails(value.trim()),
        ),
      ],
    );
  }

  Widget _submitButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final requestSubmitted = ref.watch(
          providerOfSupportRequest.select(
            (value) => value.requestSubmitted,
          ),
        );
        if (requestSubmitted) return const SizedBox.shrink();

        final hasAllRequiredDataEntered = _hasAllRequiredDataEntered(ref);
        if (!hasAllRequiredDataEntered) return const SizedBox.shrink();

        final isLoading = ref.watch(
          providerOfSupportRequest.select(
            (value) => value.submitState.when(
              initial: () => false,
              loading: () => true,
              success: () => false,
              error: (_) => false,
            ),
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorMedium,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: EdgeInsets.all(10.spMin),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SafeArea(
              child: Button.filled(
                value: 'Submit Request',
                icon: Icon(Icons.check_rounded),
                isLoading: isLoading,
                onPressed: _handleSubmitRequest,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _submitAnotherButtonBuilder() {
    return Button.bordered(
      width: 300.0,
      value: 'Submit Another Request',
      icon: Icon(Icons.add_rounded),
      onPressed: _handleAnotherRequest,
    );
  }

  Widget _closeButtonBuilder() {
    return Button.bordered(
      width: 300.0,
      value: 'Go Back',
      icon: Icon(Icons.arrow_back_rounded),
      onPressed: () => context.pop(),
    );
  }

  Widget _clearAllBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hasAnyDataEntered = _hasAnyDataEntered(ref);
        if (!hasAnyDataEntered) {
          return const SizedBox.shrink();
        }
        return RoundButton(
          icon: Icon(
            Icons.delete_rounded,
            color: AppColors.black,
            size: 24.spMin,
          ),
          size: 35.0,
          backgroundColor: AppColors.lightGrey.withValues(alpha: 0.7),
          onPressed: _clearAll,
        );
      },
    );
  }

  /// Checks if any data has been entered in the form.
  bool _hasAnyDataEntered(final WidgetRef ref) {
    return ref.watch(
      providerOfSupportRequest.select(
        (value) => value.requestType != null || value.details.isNotEmpty,
      ),
    );
  }

  /// Checks if all required data has been entered in the form.
  bool _hasAllRequiredDataEntered(final WidgetRef ref) {
    return ref.watch(
      providerOfSupportRequest.select(
        (value) => value.requestType != null && value.details.isNotEmpty,
      ),
    );
  }

  /// Gets the display info for a request type.
  Map<String, dynamic> _getRequestTypeInfo(SupportRequestType type) {
    switch (type) {
      case SupportRequestType.support:
        return {
          'title': 'Support',
          'description': 'Get help with technical issues or account problems',
          'icon': Icons.support_agent_outlined,
          'color': AppColors.blue,
        };
      case SupportRequestType.feedback:
        return {
          'title': 'Feedback',
          'description': 'Share your thoughts on how we can improve',
          'icon': Icons.feedback_outlined,
          'color': AppColors.green,
        };
      case SupportRequestType.question:
        return {
          'title': 'Question',
          'description': 'Ask questions about features or functionality',
          'icon': Icons.help_outline,
          'color': AppColors.orange,
        };
      case SupportRequestType.other:
        return {
          'title': 'Other',
          'description': 'Something else? Let us know what you need',
          'icon': Icons.more_horiz,
          'color': AppColors.grey,
        };
    }
  }

  void _onInit() {
    ref.read(providerOfSupportRequest.notifier).updateRequestSubmitted(false);
    ref.read(providerOfSupportRequest.notifier).resetAllFields();
  }

  /// Listens to changes in the submit state to show error toasts.
  void _listenToSubmitStateChanges() {
    ref.listen(
      providerOfSupportRequest.select(
        (value) => value.submitState,
      ),
      (previous, next) {
        if (previous != next) {
          next.maybeWhen(
            error: (error) {
              context.showErrorToast(
                message:
                    'Failed to submit request: ${error.message.isNotEmpty ? error.message : 'Unknown error'}',
              );
            },
            orElse: () {},
          );
        }
      },
    );
  }

  /// Handles the selection of a request type.
  void _handleRequestTypeSelect(SupportRequestType type) {
    ref.read(providerOfSupportRequest.notifier).updateRequestType(type);
    _scrollToEnd();
  }

  /// Updates the details in the state.
  void _updateDetails(final String details) {
    ref.read(providerOfSupportRequest.notifier).updateDetails(details);
  }

  /// Clears all the inputs and resets the state.
  void _clearAll() {
    context.unfocusInputs();
    _detailsController.clear();
    ref.read(providerOfSupportRequest.notifier).resetAllFields();
  }

  /// Handles the submission of the support request.
  void _handleSubmitRequest() {
    context.unfocusInputs();
    ref.read(providerOfSupportRequest.notifier).submitSupportRequest();
    _clearAll();
  }

  /// Handles the action when user wants to submit another request.
  void _handleAnotherRequest() {
    _detailsController.clear();
    ref.read(providerOfSupportRequest.notifier).updateRequestSubmitted(false);
    ref.read(providerOfSupportRequest.notifier).resetAllFields();
  }

  /// Scrolls to the end of the screen.
  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
