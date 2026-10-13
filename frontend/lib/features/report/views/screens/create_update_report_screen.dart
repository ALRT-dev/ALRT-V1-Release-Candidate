import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/report/providers/duplicate_report_provider.dart';
import 'package:hazard_app/features/report/providers/report_rate_limit_provider.dart';
import 'package:hazard_app/features/report/views/widgets/duplicate_report_sheet.dart';
import 'package:hazard_app/features/report/views/widgets/report_rate_limit_sheet.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/profile/enums/my_hazards_tab_types.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/profile/views/screens/how_points_work_screen.dart';
import 'package:hazard_app/features/profile/views/screens/my_hazards_screen.dart';
import 'package:hazard_app/features/report/providers/create_update_report_provider.dart';
import 'package:hazard_app/features/report/providers/states/create_update_report_provider_state.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/features/report/models/report_taxonomy.dart';
import 'package:hazard_app/features/report/views/widgets/create_report_medias_list.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/media_service.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/dotted_border_container.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Community report photo/video. Off for V1. Matches backend COMMUNITY_REPORT_MEDIA_ENABLED.
const bool kCommunityReportMediaEnabled = bool.fromEnvironment(
  'ALRT_REPORT_MEDIA',
  defaultValue: false,
);

/// The soft grey the report page sits on, from the V3.1 prototype.
const _pageColor = Color(0xFFF0EEF2);

/// Section labels on this page take the prototype's bright orange rather
/// than the darker V3 rust. The rust is legible but reads as brown at 10px,
/// which is most of why the page looked washed out.
const _labelColor = Color(0xFFFF6B01);

/// The tint behind a card's leading icon, and the soft lift under the card
/// itself. Flat hairline borders were the other half of the cheap look.
const _iconTint = Color(0xFFFFF3E8);
const _cardShadow = Color(0x0D1E142D);

/// The posted state: soft green disc behind the tick, the brand gradient on
/// the one primary action, and the warm grey behind the headline preview.
const _postedTickBackground = Color(0xFFE6F7EC);
const _previewFill = Color(0xFFF0EEEA);
const _brandGradientStart = Color(0xFFFF6B00);
const _brandGradientEnd = Color(0xFFFF0004);

class CreateUpdateReportScreenArgs {
  CreateUpdateReportScreenArgs({this.hazardToUpdate});

  /// The hazard to update, if any.
  /// If null, a new hazard report will be created.
  final Hazard? hazardToUpdate;
}

class CreateUpdateReportScreen extends ConsumerStatefulWidget {
  /// Displays the screen for creating or updating a hazard report.
  const CreateUpdateReportScreen({
    super.key,
    this.args,
  });

  /// The arguments for the screen.
  final CreateUpdateReportScreenArgs? args;

  static const createRoute = '/report/create';
  static const updateRoute = '/report/update';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateUpdateReportScreenState();
}

class _CreateUpdateReportScreenState
    extends ConsumerState<CreateUpdateReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();

  /// The details box when it sits under "What can you see?" ("Something
  /// else" picked), used to scroll it into view without overshooting.
  final _inlineDetailsKey = GlobalKey();

  /// Whether "Something else" is picked: the details box then moves up
  /// under the chips, so writing it never jumps the page to Submit.
  bool get _somethingElsePicked =>
      _selectedChipIds.any((id) => id.endsWith('_other'));

  /// "What can you see?": selected observation chip ids (locked taxonomy).
  final Set<String> _selectedChipIds = {};

  /// "How would you describe it?": the active wording. Pre-selected from
  /// the tapped chips until the user picks one themselves.
  ReportSeverityWording? _pickedWording;
  bool _wordingTouched = false;

  MediaService get _mediaService => ref.read(providerOfMediaService);

  @override
  void initState() {
    super.initState();
    _titleController.text =
        widget.args?.hazardToUpdate?.title ??
        ref.read(providerOfCreateReport).hazardToCreateOrUpdate.title ??
        '';
    _descriptionController.text =
        widget.args?.hazardToUpdate?.description ??
        ref.read(providerOfCreateReport).hazardToCreateOrUpdate.description ??
        '';

    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  Widget build(BuildContext context) {
    // A repeat of a live alert nearby: offer to confirm that one instead.
    ref.listen<DuplicateReport?>(providerOfDuplicateReport, (_, duplicate) {
      if (duplicate == null) return;
      ref.read(providerOfDuplicateReport.notifier).state = null;
      showDuplicateReportSheet(context: context, duplicate: duplicate);
    });

    // Rate limit (3/hour, 10/day): show the refusal sheet.
    ref.listen<String?>(providerOfReportRateLimit, (_, message) {
      if (message == null) return;
      ref.read(providerOfReportRateLimit.notifier).state = null;
      showReportRateLimitSheet(context: context, message: message);
    });

    return Scaffold(
      // The soft grey page the prototype uses. White cards float on it, so
      // each one reads as a distinct thing to do instead of dissolving into
      // a single white sheet divided by hairlines.
      backgroundColor: _pageColor,
      bottomNavigationBar: _submitBarBuilder(),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 64.spMin,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.orange.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        title: Consumer(
          builder: (context, ref, child) {
            final isUpdating = ref.watch(
              providerOfCreateReport.select(
                (value) => value.hazardToCreateOrUpdate.id?.isNotEmpty ?? false,
              ),
            );
            final reportSubmitted = ref.watch(
              providerOfCreateReport.select(
                (value) => value.reportSubmitted,
              ),
            );
            if (reportSubmitted) {
              return _submittedAppbarTitleBuilder();
            }

            // Title plus one plain line of what this screen is for, so the
            // header carries the purpose instead of a warning box.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUpdating ? 'Update an ALRT' : 'Report an ALRT',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 21.spMin,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                3.hSizedBox,
                Text(
                  'Tell your neighbours what you can see',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
              ],
            );
          },
        ),
        foregroundColor: AppColors.black,
        actions: [
          _closeButtonBuilder(),
          15.wSizedBox,
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final reportSubmitted = ref.watch(
            providerOfCreateReport.select(
              (value) => value.reportSubmitted,
            ),
          );
          return reportSubmitted ? _submittedBuilder() : _formBuilder();
        },
      ).pB(20.0),
    ).keyboardDismisser(context);
  }

  /// Every step is on the page from the first frame: nothing unfolds only
  /// after a category is picked, so the whole job is visible up front.
  Widget _formBuilder() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _disclosureBandBuilder(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.spMin,
              12.spMin,
              16.spMin,
              28.spMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _locationBuilder(),
                _sectionBuilder(
                  label: 'Category',
                  helper: 'one tap, pick the closest fit',
                  child: _categoriesBuilder(),
                ),
                _sectionBuilder(
                  label: 'What can you see?',
                  helper: 'tap any, this is an observation not a diagnosis',
                  child: _somethingElsePicked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _chipsBuilder(),
                            12.hSizedBox,
                            _inlineSomethingElseBuilder(),
                          ],
                        )
                      : _chipsBuilder(),
                ),
                _sectionBuilder(
                  label: 'How would you describe it?',
                  helper: 'auto-set from what you picked, tap to change',
                  child: _severityWordingBuilder(),
                ),
                // With "Something else" picked the details box is already
                // open under the chips; one box, never two.
                if (!_somethingElsePicked)
                  _sectionBuilder(
                    label: 'Add details',
                    helper: 'optional',
                    child: _descriptionBuilder(),
                  ),
                // Photo/video is switched off for the V1 release (privacy and
                // moderation risk). Build with --dart-define=ALRT_REPORT_MEDIA=true
                // to bring it back; the backend flag must match.
                if (kCommunityReportMediaEnabled)
                  _sectionBuilder(
                    label: 'Photos',
                    helper: 'optional',
                    child: _mediaBuilder(),
                  ),
                _headlinePreviewBuilder(),
                _clearAllBuilder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One section: a small orange label with its helper set inline, then the
  /// content straight onto the page.
  ///
  /// The numbered step circles and Required badges are gone. Six numbered
  /// cards separated by hairlines read as a government form, which is what
  /// made this screen feel like paperwork rather than telling a neighbour
  /// what you can see. The label is the quietest thing in each section and
  /// the content is the loudest, which is the right way round.
  ///
  /// Cards are plain white on a light shadow (approved Report board). The
  /// done / active / ahead coloured outlines are gone: the selected chips
  /// already say what has been answered.
  Widget _sectionBuilder({
    required final String label,
    required final Widget child,
    final String? helper,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12.spMin),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          14.spMin,
          13.spMin,
          14.spMin,
          14.spMin,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.spMin),
          boxShadow: const [
            BoxShadow(
              color: _cardShadow,
              blurRadius: 10.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10.spMin),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: label.toUpperCase()),
                    if (helper != null)
                      TextSpan(
                        text: '  $helper',
                        style: TextStyle(
                          fontSize: 12.spMin,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: _labelColor,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  /// The standing disclosure: ALRT carries a report between neighbours, it is
  /// not an emergency service. Info-band grey, stated once, never alarming.
  Widget _disclosureBandBuilder() {
    return Container(
      width: double.infinity,
      color: _pageColor,
      padding: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 4.spMin),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4ED),
          borderRadius: BorderRadius.circular(11.spMin),
          border: Border.all(
            color: AppColors.orange.withValues(alpha: 0.2),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 11.spMin,
          vertical: 9.spMin,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.info,
              size: 14.spMin,
              color: AppColors.orange,
            ),
            SizedBox(width: 8.spMin),
            Expanded(
              child: Text(
                'ALRT is a community report, not an emergency service. '
                'Report only what you can see safely. In an emergency, '
                'contact your local emergency number.',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C4A3A),
                  fontFamily: AppTheme.defaultFontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shown in place of per-category content before a category is picked, so
  /// the step is still visible and says what will land in it.
  Widget _awaitingCategoryBuilder(final String message) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(12.spMin),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 16.spMin),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14.spMin,
          color: AppColors.mediumGrey,
        ),
      ),
    );
  }

  /// "What can you see?": observation chips, never a diagnosis. Multi-tap;
  /// "Something else" focuses the details field instead of adding data.
  Widget _chipsBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final categoryName = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.category?.name,
          ),
        );
        if (categoryName == null) {
          return _awaitingCategoryBuilder(
            'Pick a category above and the things you might see appear here.',
          );
        }

        final chips = chipsForCategoryName(categoryName);
        if (chips.isEmpty) {
          return _awaitingCategoryBuilder(
            'No quick options for this category. Add details below instead.',
          );
        }

        return Wrap(
          spacing: 8.spMin,
          runSpacing: 8.spMin,
          children: [
            for (final chip in chips) _chipItemBuilder(chip),
          ],
        );
      },
    );
  }

  Widget _chipItemBuilder(final ReportChip chip) {
    final isSelected = _selectedChipIds.contains(chip.id);

    return Semantics(
      button: true,
      selected: isSelected,
      label: chip.label,
      excludeSemantics: true,
      onTap: () => _handleChipTap(chip),
      child: Container(
        constraints: BoxConstraints(minHeight: 48.spMin),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 16.spMin),
        // Selected looks like the severity choice below it (product owner
        // 12 Oct 2026): a dark outline on a soft white, never an orange fill.
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF9F7) : AppColors.white,
          borderRadius: BorderRadius.circular(11.spMin),
          border: Border.all(
            color: isSelected ? AppColors.ink : const Color(0xFFE8E4EE),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(LucideIcons.check, size: 14.spMin, color: AppColors.ink),
              6.wSizedBox,
            ],
            Text(
              chip.label,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    ).onPressed(() => _handleChipTap(chip));
  }

  void _handleChipTap(final ReportChip chip) {
    setState(() {
      if (_selectedChipIds.contains(chip.id)) {
        _selectedChipIds.remove(chip.id);
      } else {
        _selectedChipIds.add(chip.id);
      }
      if (!_wordingTouched) _pickedWording = _preselectedWording();
    });

    // "Something else" asks for words instead of adding taxonomy data.
    // The box opens right under the chips; it is focused only after it
    // has been built, then scrolled into the top third of the screen, so
    // the keyboard never pushes the page down to Submit and the severity
    // choice stays one scroll below (product owner, 14 Oct 2026).
    if (chip.isOther) {
      if (_selectedChipIds.contains(chip.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _descriptionFocusNode.requestFocus();
          Future.delayed(const Duration(milliseconds: 320), () {
            final box = _inlineDetailsKey.currentContext;
            if (!mounted || box == null || !box.mounted) return;
            Scrollable.ensureVisible(
              box,
              alignment: 0.2,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          });
        });
      } else {
        _descriptionFocusNode.unfocus();
      }
    }
  }

  /// The details box as it appears under the chips for "Something else",
  /// with a Done button so the keyboard can be closed without a stray tap
  /// landing on something else.
  Widget _inlineSomethingElseBuilder() {
    return Column(
      key: _inlineDetailsKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _inputBuilder(
          hintText: 'Tell us what you can see…',
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          contentPadding: EdgeInsets.all(14.spMin),
          borderRadius: 14.0,
          onChanged: (value) {
            _updateDescription(value.trim());
            setState(() {});
          },
        ),
        ListenableBuilder(
          listenable: _descriptionFocusNode,
          builder: (context, child) {
            if (!_descriptionFocusNode.hasFocus) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _descriptionFocusNode.unfocus(),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Highest severityDefault across the selected chips (spec A.3), or null
  /// when nothing selected, in which case no wording is highlighted.
  ReportSeverityWording? _preselectedWording() {
    final categoryName = ref
        .read(providerOfCreateReport)
        .hazardToCreateOrUpdate
        .category
        ?.name;
    int? maxDefault;
    for (final chip in chipsForCategoryName(categoryName)) {
      if (!_selectedChipIds.contains(chip.id)) continue;
      final d = chip.severityDefault;
      if (d != null && (maxDefault == null || d > maxDefault)) maxDefault = d;
    }
    return ReportSeverityWording.fromDefault(maxDefault);
  }

  /// "How would you describe it?": severity is declared by the reporter,
  /// pre-selected from the chips, never imposed.
  ///
  /// The three cards are exactly equal: IntrinsicHeight stretches every
  /// card to the tallest one, Expanded gives each the same width.
  Widget _severityWordingBuilder() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.spMin,
        children: [
          for (final wording in ReportSeverityWording.values)
            Expanded(child: _wordingItemBuilder(wording)),
        ],
      ),
    );
  }

  Widget _wordingItemBuilder(final ReportSeverityWording wording) {
    final isSelected = _pickedWording == wording;
    void handleTap() => setState(() {
      _wordingTouched = true;
      _pickedWording = isSelected ? null : wording;
    });

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${wording.label}, ${wording.sub}',
      excludeSemantics: true,
      onTap: handleTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 64.spMin),
        padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 16.spMin),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF9F7) : AppColors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.lightGrey,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        // The tick sits in the corner, not beside the word, so it never
        // takes width from the label: "Dangerous" broke as "Dangero / us"
        // on a 3-up row (phone review, 14 Oct 2026). The word itself
        // shrinks to fit rather than wrapping mid-word.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      wording.label,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  3.hSizedBox,
                  Text(
                    wording.sub,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      height: 1.25,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: -10.spMin,
                right: -4.spMin,
                child: Container(
                  width: 18.spMin,
                  height: 18.spMin,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.check,
                    size: 11.spMin,
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).onPressed(handleTap);
  }

  /// Compact category pills (V3.1 mock): coloured dot + name, everything
  /// on one page, no descriptions; the observation chips below act as
  /// the examples.
  Widget _categoriesBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final getCategoriesState = ref.watch(
          providerOfCreateReport.select(
            (value) => value.getCategoriesToSelectState,
          ),
        );
        final categories = ref.watch(
          providerOfCreateReport.select(
            (value) => value.categoriesToSelect,
          ),
        );
        final selectedCategoryId = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.category?.id,
          ),
        );

        if (categories.isEmpty) {
          return getCategoriesState.maybeWhen(
            loading: () => Text(
              'Loading categories…',
              style: TextStyle(fontSize: 13.5.spMin, color: AppColors.grey),
            ),
            error: (error) => Text(
              'Could not load categories. Please try again.',
              style: TextStyle(fontSize: 13.5.spMin, color: AppColors.grey),
            ),
            orElse: () => const SizedBox.shrink(),
          );
        }

        // The prototype's wrapped pills: the whole set is visible in three
        // short rows instead of seven full-width bars, so picking a category
        // no longer means scrolling past the rest of them.
        return Wrap(
          spacing: 6.spMin,
          runSpacing: 6.spMin,
          children: [
            for (final category in categories)
              // The same chip the map key draws, so a category looks
              // identical whether you are reading one or choosing one.
              CategoryFilterChip(
                category: category,
                isSelected: category.id == selectedCategoryId,
                isCompact: true,
                onToggle: (_) => _handleCategoryTap(category),
              ),
          ],
        );
      },
    );
  }

  void _handleCategoryTap(final HazardCategory category) {
    ref.read(providerOfCreateReport.notifier).updateCategory(category);
    // The observation chips are per-category: a switch clears them and any
    // wording they pre-selected.
    setState(() {
      _selectedChipIds.clear();
      if (!_wordingTouched) _pickedWording = null;
    });
  }

  /// The header once the report has gone: a plain title. The body below
  /// carries the thanks and what the report can earn, so the header does
  /// not repeat it.
  Widget _submittedAppbarTitleBuilder() {
    return Text(
      'Report sent',
      style: TextStyle(
        color: AppColors.black,
        fontSize: 21.spMin,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  }

  /// The posted state (approved Report board): a green tick, thanks, what
  /// the report can earn, the next badge when the ledger knows one, and one
  /// primary action back to the map.
  Widget _submittedBuilder() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.spMin, 36.spMin, 20.spMin, 24.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72.spMin,
              height: 72.spMin,
              decoration: const BoxDecoration(
                color: _postedTickBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.check,
                size: 36.spMin,
                color: AppColors.green,
              ),
            ),
          ),
          20.hSizedBox,
          Text(
            'Thanks for telling your neighbours',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.spMin,
              fontWeight: FontWeight.w700,
              height: 1.15,
              color: AppColors.black,
            ),
          ),
          10.hSizedBox,
          Text(
            'Your report is being checked. It shows as unverified until '
            'others nearby confirm it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.spMin,
              height: 1.4,
              color: AppColors.mediumGrey,
            ),
          ),
          24.hSizedBox,
          _whatThisEarnsBuilder(),
          _nextBadgeBuilder(),
          24.hSizedBox,
          SizedBox(
            height: 54.spMin,
            child: Button.gradient(
              value: 'Back to the map',
              gradient: const LinearGradient(
                colors: [_brandGradientStart, _brandGradientEnd],
              ),
              borderRadius: 16.0,
              valueStyle: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              onPressed: _handleBackToMap,
            ),
          ),
          14.hSizedBox,
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleSeeMyReports,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.spMin,
                  vertical: 6.spMin,
                ),
                child: Text(
                  'See my reports',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// What this report can earn, stated at the only moment the user is
  /// certain to be looking: right after they sent it.
  ///
  /// Every line is conditional on purpose. Nothing is awarded at submission
  /// (approval, corroboration and an official match all happen later), so
  /// the card says "if", never "you earned". Claiming points that a
  /// moderator has not granted would be the one dishonest screen in the app.
  Widget _whatThisEarnsBuilder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: _cardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'POINTS YOU CAN EARN',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: _labelColor,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(HowPointsWorkScreen.route),
                child: Text(
                  'How points work',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
          12.hSizedBox,
          _earnLineBuilder(
            points: '+10',
            text: 'when a moderator approves it',
            isPrimary: true,
          ),
          _earnLineBuilder(
            points: '+5',
            text: 'if someone nearby confirms the same thing',
          ),
          _earnLineBuilder(
            points: '+15',
            text: 'if it matches an official warning',
          ),
          6.hSizedBox,
          Text(
            'Points reward careful, accurate reports. Reporting more does '
            'not earn more.',
            style: TextStyle(
              fontSize: 12.5.spMin,
              height: 1.4,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnLineBuilder({
    required final String points,
    required final String text,
    final bool isPrimary = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.spMin,
            child: Text(
              points,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w800,
                color: isPrimary ? AppColors.orange : AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.4,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The next badge still to earn, with how far off it is. Shown only when
  /// the XP summary has loaded and holds a locked badge with a threshold;
  /// nothing is invented when the ledger is quiet.
  Widget _nextBadgeBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final badges = ref.watch(
          providerOfXpSummary.select(
            (summary) => summary.value?.badges ?? const <SafetyBadge>[],
          ),
        );
        SafetyBadge? next;
        for (final badge in badges) {
          if (badge.earned || badge.threshold <= 0) continue;
          if (next == null || badge.fraction > next.fraction) next = badge;
        }
        if (next == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 12.spMin),
          padding: EdgeInsets.symmetric(
            horizontal: 16.spMin,
            vertical: 14.spMin,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.spMin),
            boxShadow: const [
              BoxShadow(
                color: _cardShadow,
                blurRadius: 10.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEXT BADGE',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: _labelColor,
                ),
              ),
              10.hSizedBox,
              Row(
                children: [
                  Icon(
                    LucideIcons.award,
                    size: 18.spMin,
                    color: AppColors.orange,
                  ),
                  8.wSizedBox,
                  Expanded(
                    child: Text(
                      next.name,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Text(
                    '${next.progress} of ${next.threshold}',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
              10.hSizedBox,
              ClipRRect(
                borderRadius: BorderRadius.circular(4.spMin),
                child: LinearProgressIndicator(
                  value: next.fraction,
                  minHeight: 6.spMin,
                  backgroundColor: AppColors.extraLightGrey,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Back to the map tab, then off this screen.
  void _handleBackToMap() {
    ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(HomeScreen.route);
    }
  }

  /// The same route and arguments the profile uses for "My reports".
  void _handleSeeMyReports() {
    ref.read(providerOfHomeTab.notifier).state = HomeTab.profile;
    context.push(
      MyHazardsScreen.route,
      extra: const MyHazardsScreenArgs(initialTab: MyHazardsTab.accepted),
    );
  }

  Widget _sectionTitleBuilder({
    required final String title,
    final int? step,
    final bool? isRequired = false,
  }) {
    return Row(
      children: [
        if (step != null) ...[
          Container(
            width: 19.spMin,
            height: 19.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _labelColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w800,
                color: _labelColor,
              ),
            ),
          ),
          SizedBox(width: 8.spMin),
        ],
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13.5.spMin,
              color: _labelColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (isRequired == true)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orange300,
                  AppColors.red200,
                ],
              ),
              borderRadius: BorderRadius.circular(20.spMin),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 2.spMin,
            ),
            child: Text(
              'Required',
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          )
        else if (isRequired == false)
          Text(
            'optional',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w400,
              color: AppColors.grey.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _inputBuilder({
    required final String hintText,
    final TextEditingController? controller,
    final FocusNode? focusNode,
    final String? value,
    final int? maxLines,
    final int? minLines,
    final TextCapitalization textCapitalization = TextCapitalization.none,
    final TextInputType? keyboardType,
    final EdgeInsetsGeometry? contentPadding,
    final double? borderRadius,
    final bool enabled = true,
    final VoidCallback? onPressed,
    final Function(String)? onChanged,
  }) {
    final border = borderRadius == null
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius.spMin),
            borderSide: BorderSide(
              color: AppColors.lightGrey,
            ),
          );

    return TextFormField(
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      controller: controller ?? TextEditingController(text: value),
      focusNode: focusNode,
      style: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.grey.withValues(alpha: 0.8),
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: contentPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: border?.copyWith(
          borderSide: BorderSide(
            color: AppColors.orange,
            width: 1.2,
          ),
        ),
        disabledBorder: context.theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(
            color: AppColors.lightGrey,
          ),
        ),
      ),
      onChanged: onChanged,
    ).onPressed(onPressed);
  }

  // ignore: unused_element
  Widget _titleBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.spMin,
      children: [
        _sectionTitleBuilder(title: 'Title'),
        _inputBuilder(
          hintText: 'Brief description',
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) => _updateTitle(value.trim()),
        ),
      ],
    );
  }

  Widget _locationBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.spMin,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final locationName = ref.watch(
              providerOfCreateReport.select(
                (value) => value.hazardToCreateOrUpdate.locationName,
              ),
            );
            // Location is auto-filled from GPS and posted from the actual
            // location, no adjust pin. The card is read-only.
            // Plain white like every other card: the text says whether the
            // location has been found, so no coloured ring is needed.
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18.spMin),
                boxShadow: const [
                  BoxShadow(
                    color: _cardShadow,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 13.spMin,
                vertical: 11.spMin,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.spMin,
                    height: 32.spMin,
                    decoration: BoxDecoration(
                      color: _iconTint,
                      borderRadius: BorderRadius.circular(10.spMin),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 16.spMin,
                      color: _labelColor,
                    ),
                  ),
                  SizedBox(width: 10.spMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationName ?? 'Finding your location...',
                          style: TextStyle(
                            fontSize: 14.5.spMin,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        2.hSizedBox,
                        Text(
                          'Your current location',
                          style: TextStyle(
                            fontSize: 12.spMin,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _headlinePreviewBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final categoryName = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.category?.name,
          ),
        );
        final locationName = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.locationName,
          ),
        );
        final headline = _assembleHeadline(
          categoryName: categoryName,
          locationName: locationName,
        );

        // The preview reports back what the choices above already decided:
        // the headline as it will read on the map, and how it is posted.
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 16.spMin),
          decoration: BoxDecoration(
            color: _previewFill,
            borderRadius: BorderRadius.circular(16.spMin),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 13.spMin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HEADLINE PREVIEW',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: _labelColor,
                ),
              ),
              8.hSizedBox,
              Text(
                headline,
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: AppColors.black,
                ),
              ),
              4.hSizedBox,
              Text(
                'Unverified · posted anonymously',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Headline fallback ladder (locked spec A.4), first match wins:
  /// chips → chip fragment; details → first sentence to 60 chars;
  /// otherwise "{category} report, {suburb}".
  String _assembleHeadline({
    required final String? categoryName,
    required final String? locationName,
  }) {
    final suffix = locationName == null ? '' : ', $locationName';

    final selectedChips = chipsForCategoryName(
      categoryName,
    ).where((c) => _selectedChipIds.contains(c.id) && !c.isOther).toList();
    if (selectedChips.isNotEmpty) {
      selectedChips.sort(
        (a, b) => (b.severityDefault ?? -1).compareTo(a.severityDefault ?? -1),
      );
      return '${selectedChips.first.headline}$suffix';
    }

    final details = _descriptionController.text.trim();
    if (details.isNotEmpty) {
      var sentence = details.split(RegExp(r'[.\n!?]')).first.trim();
      if (sentence.length > 60) sentence = '${sentence.substring(0, 57)}…';
      if (sentence.isNotEmpty) return '$sentence$suffix';
    }

    if (categoryName != null) return '$categoryName report$suffix';
    return locationName == null
        ? 'Your report will appear here'
        : 'Community report$suffix';
  }

  Widget _descriptionBuilder() {
    final hasOtherChip = _selectedChipIds.any((id) => id.endsWith('_other'));

    return _inputBuilder(
      hintText: hasOtherChip
          ? 'Tell us what you can see…'
          : 'Water over both lanes near the bridge...',
      controller: _descriptionController,
      focusNode: _descriptionFocusNode,
      minLines: 5,
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      contentPadding: EdgeInsets.all(15.spMin),
      borderRadius: 16.0,
      onChanged: (value) {
        _updateDescription(value.trim());
        // The headline ladder can depend on the details text.
        setState(() {});
      },
    );
  }

  Widget _mediaBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hasMedias = ref.watch(
          providerOfCreateReport.select(
            (value) => value.medias.isNotEmpty,
          ),
        );
        if (!hasMedias) return _mediaPickerBuilder();
        return CreateReportMediasList();
      },
    );
  }

  Widget _mediaPickerBuilder() {
    return Row(
      spacing: 10.spMin,
      children: [
        // Camera Button
        Expanded(
          child: _mediaPickerButtonBuilder(
            icon: LucideIcons.camera,
            label: 'Camera',
            onPressed: _handleCameraPress,
          ),
        ),
        // Gallery Button
        Expanded(
          child: _mediaPickerButtonBuilder(
            icon: LucideIcons.image,
            label: 'Gallery',
            onPressed: _handleGalleryPress,
          ),
        ),
      ],
    );
  }

  Widget _mediaPickerButtonBuilder({
    required final IconData icon,
    required final String label,
    required final VoidCallback onPressed,
  }) {
    // Two 115px dotted boxes gave an optional step more of the page than
    // the required ones above it. Same targets, a third of the height, and
    // the icon takes the tinted square the rest of the page now uses.
    return DottedBorderContainer(
      strokeWidth: 1.2,
      borderRadius: 12.spMin,
      borderColor: AppColors.lightGrey,
      child: Container(
        width: double.infinity,
        height: 76.spMin,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.spMin),
        ),
        child: Column(
          spacing: 6.spMin,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.spMin,
              height: 30.spMin,
              decoration: BoxDecoration(
                color: _iconTint,
                borderRadius: BorderRadius.circular(9.spMin),
              ),
              child: Icon(icon, color: _labelColor, size: 16.spMin),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ).onPressed(onPressed),
    );
  }

  /// Pinned to the bottom so the action, and what is still missing before it
  /// can be tapped, are visible without scrolling the form.
  Widget _submitBarBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final reportSubmitted = ref.watch(
          providerOfCreateReport.select(
            (value) => value.reportSubmitted,
          ),
        );
        if (reportSubmitted) return const SizedBox.shrink();

        final hasCategory = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.category != null,
          ),
        );
        final hasLocation = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.locationName != null,
          ),
        );
        final isReady = hasCategory && hasLocation;

        final missing = <String>[
          if (!hasLocation) 'a location',
          if (!hasCategory) 'a category',
        ];

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.lightGrey, width: 1.0),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            16.spMin,
            12.spMin,
            16.spMin,
            10.spMin,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 54.spMin,
                  child: Button.filled(
                    value: 'Submit report',
                    color: AppColors.orange,
                    borderRadius: 16.0,
                    // No colour here: the theme greys the label with the
                    // button while a location or category is still missing.
                    valueStyle: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                    onPressed: isReady ? _handleSubmitReport : null,
                  ),
                ),
                8.hSizedBox,
                Text(
                  isReady
                      ? 'Shows as unverified until others nearby confirm it.'
                      : 'Add ${missing.join(' and ')} to submit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.grey.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// A 40 px white round close button in the header. Closing is not
  /// clearing: whatever was typed stays in the provider for next time.
  Widget _closeButtonBuilder() {
    return Semantics(
      button: true,
      label: 'Close',
      child: Container(
        width: 40.spMin,
        height: 40.spMin,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: _cardShadow,
              blurRadius: 10.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          LucideIcons.x,
          color: AppColors.black,
          size: 20.spMin,
        ),
      ).onPressed(() {
        context.unfocusInputs();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(HomeScreen.route);
        }
      }),
    );
  }

  /// A quiet "Clear all" under the form, shown only once something has been
  /// entered. It used to be a trash icon in the header, where it read as a
  /// delete button.
  Widget _clearAllBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hasAnyDataEntered = _hasAnyDataEntered(ref);
        if (!hasAnyDataEntered) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(top: 14.spMin),
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _clearAll,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.spMin,
                  vertical: 6.spMin,
                ),
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Checks if any data has been entered in the form.
  bool _hasAnyDataEntered(final WidgetRef ref) {
    return ref.watch(
      providerOfCreateReport.select(
        (value) =>
            value.hazardToCreateOrUpdate.category != null ||
            (value.hazardToCreateOrUpdate.title?.isNotEmpty ?? false) ||
            value.hazardToCreateOrUpdate.locationName != null ||
            (value.hazardToCreateOrUpdate.description?.isNotEmpty ?? false) ||
            value.medias.isNotEmpty,
      ),
    );
  }

  void _onInit() {
    ref.read(providerOfCreateReport.notifier).updateReportSubmitted(false);

    ref.read(providerOfCreateReport.notifier)
      ..updateHazardToCreateOrUpdate(widget.args?.hazardToUpdate ?? Hazard())
      ..updateMedias(widget.args?.hazardToUpdate?.processedMedias ?? [])
      ..updateShowCategoriesSelector(
        widget.args?.hazardToUpdate?.category == null,
      )
      ..prefillLocationFromCurrentPosition();
  }

  /// Updates the title in the state.
  void _updateTitle(final String title) {
    ref.read(providerOfCreateReport.notifier).updateTitle(title);
  }

  /// Updates the description in the state.
  void _updateDescription(final String description) {
    ref.read(providerOfCreateReport.notifier).updateDescription(description);
  }

  /// Clears all the inputs and resets the state.
  void _clearAll() {
    context.unfocusInputs();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedChipIds.clear();
      _pickedWording = null;
      _wordingTouched = false;
    });
    ref.read(providerOfCreateReport.notifier).resetAllFields();
  }

  /// Folds the tap-first taxonomy into the report payload right before
  /// submitting: declared severity, the assembled headline as the title,
  /// and the chip labels prefixed to the details so reviewers and
  /// corroborators see exactly what was tapped.
  void _applyTaxonomyToReport() {
    final notifier = ref.read(providerOfCreateReport.notifier);
    final hazard = ref.read(providerOfCreateReport).hazardToCreateOrUpdate;
    final categoryName = hazard.category?.name;
    if (categoryName == null) return;

    if (_pickedWording != null) {
      notifier.updateSeverity(_pickedWording!.severity);
    }

    notifier.updateTitle(
      _assembleHeadline(
        categoryName: categoryName,
        locationName: hazard.locationName,
      ),
    );

    final chipLabels = chipsForCategoryName(categoryName)
        .where((c) => _selectedChipIds.contains(c.id) && !c.isOther)
        .map((c) => c.label)
        .toList();
    if (chipLabels.isNotEmpty) {
      final details = _descriptionController.text.trim();
      notifier.updateDescription(
        details.isEmpty
            ? 'Seen: ${chipLabels.join(', ')}.'
            : 'Seen: ${chipLabels.join(', ')}.\n$details',
      );
    }
  }

  /// Handles the submission of the report.
  void _handleSubmitReport() {
    final isUpdating = ref.read(
      providerOfCreateReport.select(
        (value) => value.hazardToCreateOrUpdate.id?.isNotEmpty ?? false,
      ),
    );

    if (isUpdating) {
      showConfirmationSheet(
        context: context,
        title: 'Update Report',
        description:
            'Are you sure you want to update this report? This will reset your votes that you have received in this alert and send the alert back for review.',
        onPressedConfirm: (context, ref) {
          ref.read(providerOfCreateReport.notifier).createOrUpdateReport();
          _clearAll();
        },
      );
    } else {
      _applyTaxonomyToReport();
      ref.read(providerOfCreateReport.notifier).createOrUpdateReport();
      _clearAll();
    }
  }

  Future<void> _handleCameraPress() async {
    final result = await _mediaService.pickImage(
      source: ImageSource.camera,
    );
    if (!mounted) return;

    result.when(
      (media) {
        if (media != null) {
          ref.read(providerOfCreateReport.notifier).addMedias([media]);
        }
      },
      (error) {
        context.showErrorToast(
          message: 'We were unable to pick media. Please try again.',
        );
      },
    );
  }

  Future<void> _handleGalleryPress() async {
    final result = await _mediaService.pickMedias();
    if (!mounted) return;

    result.when(
      (medias) {
        ref.read(providerOfCreateReport.notifier).addMedias(medias);
      },
      (error) {
        context.showErrorToast(
          message: 'We were unable to pick media. Please try again.',
        );
      },
    );
  }
}
