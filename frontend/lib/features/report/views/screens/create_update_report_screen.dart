import 'dart:math';

import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
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

/// The chip treatment the prototype gives secondary actions.
const _chipFill = Color(0xFFF0F2F5);

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

  /// "What can you see?" — selected observation chip ids (locked taxonomy).
  final Set<String> _selectedChipIds = {};

  /// "How would you describe it?" — the active wording. Pre-selected from
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
    return Scaffold(
      // The soft grey page the prototype uses. White cards float on it, so
      // each one reads as a distinct thing to do instead of dissolving into
      // a single white sheet divided by hairlines.
      backgroundColor: _pageColor,
      bottomNavigationBar: _submitBarBuilder(),
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.orange300,
                AppColors.red200,
              ],
            ),
          ),
        ),
        centerTitle: false,
        toolbarHeight: 64.spMin,
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
                    color: AppColors.white,
                    fontSize: 21.spMin,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                3.hSizedBox,
                Text(
                  'Tell your neighbours what you can see',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
              ],
            );
          },
        ),
        foregroundColor: AppColors.white,
        actions: [
          _clearAllBuilder(),
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

  /// Every step is on the page from the first frame — nothing unfolds only
  /// after a category is picked, so the whole job is visible up front.
  Widget _formBuilder() {
    // Read once for the step ticks, so each card can show whether it is
    // done without every section watching the provider separately.
    final report = ref.watch(providerOfCreateReport);
    final hazard = report.hazardToCreateOrUpdate;
    // Nothing below location glows until location is answered, so there
    // is exactly one lit box at a time and the order is obvious without
    // numbering it.
    final hasLocation = (hazard.locationName ?? '').trim().isNotEmpty;
    final hasCategory = (hazard.categoryId ?? '').isNotEmpty;
    final hasSeverityWording = hazard.severity != null;
    final hasMedia = report.medias.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _disclosureBandBuilder(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 28.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _locationBuilder(),
                _sectionBuilder(
                  isDone: hasCategory,
                  isUnlocked: hasLocation,
                  label: 'Category',
                  helper: 'one tap, pick the closest fit',
                  child: _categoriesBuilder(),
                ),
                _sectionBuilder(
                  isDone: _selectedChipIds.isNotEmpty,
                  isUnlocked: hasLocation,
                  label: 'What can you see?',
                  helper: 'tap any, this is an observation not a diagnosis',
                  child: _chipsBuilder(),
                ),
                _sectionBuilder(
                  isDone: hasSeverityWording,
                  isUnlocked: hasLocation,
                  label: 'How would you describe it?',
                  helper: 'auto-set from what you picked, tap to change',
                  child: _severityWordingBuilder(),
                ),
                _sectionBuilder(
                  isOptional: true,
                  isDone: _descriptionController.text.trim().isNotEmpty,
                  label: 'Add details',
                  helper: 'optional',
                  child: _descriptionBuilder(),
                ),
                _sectionBuilder(
                  isOptional: true,
                  isDone: hasMedia,
                  label: 'Photos',
                  helper: 'optional',
                  child: _mediaBuilder(),
                ),
                _headlinePreviewBuilder(),
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
  Widget _sectionBuilder({
    required final String label,
    required final Widget child,
    final String? helper,
    final bool isDone = false,
    final bool isOptional = false,
    final bool isUnlocked = true,
  }) {
    // The steps are highlighted so the order is obvious at a glance:
    // done goes green, the one you are up to wears the orange outline,
    // and anything still ahead stays quiet. Optional steps never nag.
    // No numbers: the glow says which box wants you next. Done goes green
    // and settles down, the one you are up to carries a lit orange ring,
    // and optional boxes never demand attention.
    final isActive = !isDone && !isOptional && isUnlocked;
    final outline = isDone
        ? const Color(0xFF17A05E)
        : isActive
            ? _labelColor
            : const Color(0xFFE8E4EE);

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
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(
            color: outline.withValues(alpha: isDone || isActive ? 0.9 : 0.5),
            width: (isActive ? 2.0 : isDone ? 1.6 : 1.0).spMin,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: _labelColor.withValues(alpha: 0.28),
                blurRadius: 22.0,
                spreadRadius: 1.5,
              )
            else
              const BoxShadow(
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.orange300, AppColors.red200],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.spMin, 0, 16.spMin, 14.spMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(11.spMin),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.25),
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
              color: AppColors.white,
            ),
            SizedBox(width: 8.spMin),
            Expanded(
              child: Text(
                'ALRT is a community report, not an emergency service. '
                'Report only what you can see safely.',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
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

  /// "What can you see?" — observation chips, never a diagnosis. Multi-tap;
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

    return GestureDetector(
      onTap: () => _handleChipTap(chip),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 8.spMin),
        decoration: BoxDecoration(
          color: isSelected
              ? _labelColor.withValues(alpha: 0.16)
              : AppColors.white,
          borderRadius: BorderRadius.circular(11.spMin),
          border: Border.all(
            color: isSelected ? _labelColor : const Color(0xFFE8E4EE),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _labelColor.withValues(alpha: 0.28),
                    blurRadius: 12.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          chip.label,
          style: TextStyle(
            fontSize: 15.spMin,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? _labelColor : AppColors.black,
          ),
        ),
      ),
    );
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
    if (chip.isOther && _selectedChipIds.contains(chip.id)) {
      _descriptionFocusNode.requestFocus();
    }
  }

  /// Highest severityDefault across the selected chips (spec A.3), or null
  /// when nothing selected — then no wording is highlighted.
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

  /// "How would you describe it?" — severity is declared by the reporter,
  /// pre-selected from the chips, never imposed.
  Widget _severityWordingBuilder() {
    return Row(
      spacing: 8.spMin,
      children: [
        for (final wording in ReportSeverityWording.values)
          Expanded(child: _wordingItemBuilder(wording)),
      ],
    );
  }

  Widget _wordingItemBuilder(final ReportSeverityWording wording) {
    final isSelected = _pickedWording == wording;

    return GestureDetector(
      onTap: () => setState(() {
        _wordingTouched = true;
        _pickedWording = isSelected ? null : wording;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 10.spMin),
        decoration: BoxDecoration(
          color: isSelected
              ? _labelColor.withValues(alpha: 0.16)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected ? _labelColor : const Color(0xFFE8E4EE),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _labelColor.withValues(alpha: 0.28),
                    blurRadius: 12.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              wording.label,
              style: TextStyle(
                fontSize: 15.5.spMin,
                fontWeight: FontWeight.w700,
                color: isSelected ? _labelColor : AppColors.black,
              ),
            ),
            2.hSizedBox,
            Text(
              wording.sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact category pills (V3.1 mock): coloured dot + name, everything
  /// on one page, no descriptions — the observation chips below act as
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

  Widget _submittedAppbarTitleBuilder() {
    return Row(
      children: [
        Container(
          width: 38.spMin,
          height: 38.spMin,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.star,
            size: 16.spMin,
            color: AppColors.white,
          ),
        ),
        8.wSizedBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your ALRT has been submitted!',
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                  letterSpacing: -0.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: AppTheme.defaultFontFamily,
                  ),
                  children: [
                    TextSpan(
                      text: 'Once approved you will gain ',
                    ),
                    TextSpan(
                      text: '+10 points ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: '- keep it up!',
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _submittedBuilder() {
    final line = Center(
      child: Container(
        height: 15.spMin,
        width: 2.5,
        decoration: BoxDecoration(
          color: const Color(0xFF3CBE5F),
          borderRadius: BorderRadius.circular(10.spMin),
        ),
      ),
    );
    final offset = 6.spMin;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110.spMin,
                width: 110.spMin,
                decoration: BoxDecoration(
                  color: Color(0xFF3CBE5F).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColorLight,
                      blurRadius: 6.0,
                      offset: const Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 80.spMin,
                    height: 80.spMin,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3CBE5F).withValues(alpha: 0.8),
                          AppColors.darkGreen.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.4),
                          blurRadius: 20.spMin,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 50.spMin,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              /// Top line
              Positioned(
                top: -offset,
                left: 0.0,
                right: 0.0,
                child: line,
              ),

              /// Bottom line
              Positioned(
                bottom: -offset,
                left: 0.0,
                right: 0.0,
                child: line,
              ),

              /// Left line
              Positioned(
                top: 0.0,
                bottom: 0.0,
                left: -offset,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: line,
                ),
              ),

              /// Right line
              Positioned(
                top: 0.0,
                bottom: 0.0,
                right: -offset,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: line,
                ),
              ),

              /// Top-left corner line
              Positioned(
                top: offset + 6.0,
                left: offset + 6.0,
                child: Center(
                  child: Transform.rotate(
                    angle: -pi / 4,
                    child: line,
                  ),
                ),
              ),

              /// Top-right corner line
              Positioned(
                top: offset + 6.0,
                right: offset + 6.0,
                child: Center(
                  child: Transform.rotate(
                    angle: pi / 4,
                    child: line,
                  ),
                ),
              ),

              /// Bottom-left corner line
              Positioned(
                bottom: offset + 6.0,
                left: offset + 6.0,
                child: Center(
                  child: Transform.rotate(
                    angle: pi / 4,
                    child: line,
                  ),
                ),
              ),

              /// Bottom-right corner line
              Positioned(
                bottom: offset + 6.0,
                right: offset + 6.0,
                child: Center(
                  child: Transform.rotate(
                    angle: -pi / 4,
                    child: line,
                  ),
                ),
              ),
            ],
          ),
          30.hSizedBox,
          Text(
            'ALRT Submitted!',
            style: TextStyle(
              fontSize: 24.spMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          5.hSizedBox,
          Text(
            'Thank you for keeping your community safe.\nYour ALRT has been submitted for review.',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.normal,
              color: AppColors.mediumGrey,
            ),
            textAlign: TextAlign.center,
          ),
          20.hSizedBox,
          _whatThisEarnsBuilder(),
          20.hSizedBox,
          _submitAnotherButtonBuilder(),
          12.hSizedBox,
          _seeActiveReportsButtonBuilder(),
        ],
      ).pX(20.0),
    );
  }

  /// What this report can earn, stated at the only moment the user is
  /// certain to be looking: right after they sent it.
  ///
  /// Every line is conditional on purpose. Nothing is awarded at submission
  /// — approval, corroboration and an official match all happen later — so
  /// the card says "if", never "you earned". Claiming points that a
  /// moderator has not granted would be the one dishonest screen in the app.
  Widget _whatThisEarnsBuilder() {
    final summary = ref.watch(providerOfXpSummary).value;
    final streakDays = summary?.streakDays ?? 0;
    final multiplierActive = summary?.streakMultiplierActive ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: const Color(0xFFF6DCC4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT THIS CAN EARN',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: _labelColor,
            ),
          ),
          10.hSizedBox,
          _earnLineBuilder(
            points: '+10',
            text: 'when a moderator approves it',
          ),
          _earnLineBuilder(
            points: '+5',
            text: 'if someone nearby reports the same thing',
          ),
          _earnLineBuilder(
            points: '+15',
            text: 'if it matches an official warning',
          ),
          if (streakDays > 0) ...[
            8.hSizedBox,
            Row(
              children: [
                Icon(
                  LucideIcons.flame,
                  size: 14.spMin,
                  color: const Color(0xFFE05A00),
                ),
                8.wSizedBox,
                Expanded(
                  child: Text(
                    multiplierActive
                        ? '$streakDays-day streak: approvals count 1.2x '
                              'while it lasts.'
                        : '$streakDays-day streak. Reach 3 days and '
                              'approvals count 1.2x.',
                    style: TextStyle(
                      fontSize: 13.spMin,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8A5A2B),
                    ),
                  ),
                ),
              ],
            ),
          ],
          10.hSizedBox,
          GestureDetector(
            onTap: () => context.push(HowPointsWorkScreen.route),
            child: Text(
              'How points work',
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w700,
                color: _labelColor,
                decoration: TextDecoration.underline,
                decorationColor: _labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnLineBuilder({
    required final String points,
    required final String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.spMin,
            child: Text(
              points,
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A8A58),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.4,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
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
            // Location is the first thing asked for, so it wears the glow
            // until it is answered. Everything below it stays quiet until
            // then: one lit box at a time is the whole point.
            final hasLocation = (locationName ?? '').trim().isNotEmpty;
            return GestureDetector(
              onTap: _gotoSelectLocationScreen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.spMin),
                  border: Border.all(
                    color: hasLocation
                        ? const Color(0xFF17A05E)
                        : _labelColor,
                    width: (hasLocation ? 1.6 : 2.0).spMin,
                  ),
                  boxShadow: [
                    if (!hasLocation)
                      BoxShadow(
                        color: _labelColor.withValues(alpha: 0.28),
                        blurRadius: 22.0,
                        spreadRadius: 1.5,
                      )
                    else
                      const BoxShadow(
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
                            locationName ?? 'Finding your location…',
                            style: TextStyle(
                              fontSize: 14.5.spMin,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          2.hSizedBox,
                          Text(
                            locationName == null
                                ? 'Tap to set it manually'
                                : 'Your current location · auto-filled',
                            style: TextStyle(
                              fontSize: 12.spMin,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.spMin),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.spMin,
                        vertical: 7.spMin,
                      ),
                      decoration: BoxDecoration(
                        color: _chipFill,
                        borderRadius: BorderRadius.circular(10.spMin),
                      ),
                      child: Text(
                        'Adjust',
                        style: TextStyle(
                          fontSize: 12.5.spMin,
                          fontWeight: FontWeight.w800,
                          color: _labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
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

        // The preview is a footnote, not a step: it reports back what the
        // choices above already decided, so it takes the quietest treatment
        // on the page rather than a section label of its own.
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 16.spMin),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5F2),
            borderRadius: BorderRadius.circular(12.spMin),
            border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.6)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 13.spMin,
            vertical: 11.spMin,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Headline preview:  ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.mediumGrey,
                  ),
                ),
                TextSpan(
                  text: headline,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 14.spMin,
              height: 1.5,
              fontFamily: AppTheme.defaultFontFamily,
            ),
          ),
        );
      },
    );
  }

  /// Headline fallback ladder (locked spec A.4), first match wins:
  /// chips → chip fragment; details → first sentence to 60 chars;
  /// otherwise "{category} report — {suburb}".
  String _assembleHeadline({
    required final String? categoryName,
    required final String? locationName,
  }) {
    final suffix = locationName == null ? '' : ' — $locationName';

    final selectedChips = chipsForCategoryName(categoryName)
        .where((c) => _selectedChipIds.contains(c.id) && !c.isOther)
        .toList();
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
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorMedium,
                blurRadius: 16.0,
                offset: const Offset(0, -2),
              ),
            ],
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
                Button.gradient(
                  value: 'Submit report',
                  icon: Icon(Icons.check_rounded),
                  borderRadius: 16.0,
                  onPressed: isReady ? _handleSubmitReport : null,
                ),
                8.hSizedBox,
                Text(
                  isReady
                      ? 'Shows as unverified until others nearby confirm it. '
                            'No points for posting, points for being right.'
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

  Widget _submitAnotherButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isUpdating = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.id?.isNotEmpty ?? false,
          ),
        );
        if (isUpdating) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorLight,
                blurRadius: 6.0,
                offset: const Offset(0.0, 0.0),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 15.spMin,
          ),
          child: Center(
            child: Row(
              spacing: 10.spMin,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: AppColors.black,
                ),
                Text(
                  'Submit Another Report',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ).onPressed(_handleAnotherReport);
      },
    );
  }

  Widget _seeActiveReportsButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isUpdating = ref.watch(
          providerOfCreateReport.select(
            (value) => value.hazardToCreateOrUpdate.id?.isNotEmpty ?? false,
          ),
        );
        if (isUpdating) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorLight,
                blurRadius: 6.0,
                offset: const Offset(0.0, 0.0),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 15.spMin,
          ),
          child: Center(
            child: Row(
              spacing: 10.spMin,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_rounded, color: AppColors.black),
                Text(
                  'See My Active Reports',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ).onPressed(() {
          ref.read(providerOfHomeTab.notifier).state = HomeTab.profile;
          context.push(MyHazardsScreen.route);
        });
      },
    );
  }

  Widget _clearAllBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hasAnyDataEntered = _hasAnyDataEntered(ref);
        if (!hasAnyDataEntered) {
          return const SizedBox.shrink();
        }
        return Container(
          width: 32.spMin,
          height: 32.spMin,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.spMin),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Icon(
            LucideIcons.trash2,
            color: AppColors.white.withValues(alpha: 0.8),
            size: 16.spMin,
          ),
        ).onPressed(_clearAll);
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

  /// Navigates to the Select Location screen.
  void _gotoSelectLocationScreen() async {
    context.unfocusInputs();

    final selectedLocation = ref.read(
      providerOfCreateReport.select(
        (value) =>
            value.hazardToCreateOrUpdate.latitude == null ||
                value.hazardToCreateOrUpdate.longitude == null
            ? null
            : AlrtLocation(
                latitude: value.hazardToCreateOrUpdate.latitude!,
                longitude: value.hazardToCreateOrUpdate.longitude!,
                name: value.hazardToCreateOrUpdate.locationName,
              ),
      ),
    );
    final userLocation = ref.read(
      providerOfLocation.select(
        (value) => value.location,
      ),
    );

    final location = await context.push(
      SelectLocationScreen.route,
      extra: SelectLocationScreenArgs(
        initialLocation: selectedLocation,
        getSubUrbOnly: true,
        centerLocation: userLocation,
        radiusInMeters: 5000,
      ),
    );
    if (!mounted) return;

    if (location != null && location is AlrtLocation) {
      _updateLocation(location);
    }
  }

  /// Updates the title in the state.
  void _updateTitle(final String title) {
    ref.read(providerOfCreateReport.notifier).updateTitle(title);
  }

  /// Updates the location in the state.
  void _updateLocation(final AlrtLocation location) {
    ref.read(providerOfCreateReport.notifier).updateLocation(location);
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

  /// Handles the action when user wants to submit another report.
  void _handleAnotherReport() {
    ref.read(providerOfCreateReport.notifier).updateReportSubmitted(false);
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
