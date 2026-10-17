import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The shared pieces of the approved ALRT screen map ("the boards'
/// language") for the Family settings screens: a white header with a plain
/// back chevron and a 24/700 title, the lavender page, white 18 px cards,
/// orange uppercase section labels, a quiet note panel, the orange primary
/// button (or the indigo family gradient), outlined secondary buttons,
/// radio cards, toggles, rows with a chevron and bottom sheets.
///
/// Mirrors the prototype's ui.js helpers (page, hdr, body, card, label,
/// note, primary, secondary, small, ghost, radio, toggle, row, group,
/// pill, chip, sh1) so every screen built from here looks like the board.

/// A board screen: white header, lavender page, a scrolling column.
class FamilyBoardScaffold extends StatelessWidget {
  const FamilyBoardScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.onBack,
    this.gap = 14,
    this.bottomBar,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> children;

  /// Space between the body's blocks (the prototype's body gap).
  final double gap;

  /// Optional pinned bar under the scrolling body.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (final (index, child) in children.indexed) {
      if (index > 0) spaced.add(SizedBox(height: gap.spMin));
      spaced.add(child);
    }
    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      bottomNavigationBar: bottomBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FamilyBoardHeader(title: title, subtitle: subtitle, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16.spMin,
                14.spMin,
                16.spMin,
                24.spMin + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: spaced,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The board header: white, back chevron, 24/700 title, optional subtitle.
class FamilyBoardHeader extends StatelessWidget {
  const FamilyBoardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.spMin, 8.spMin, 16.spMin, 12.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: InkWell(
                      key: const Key('board-back'),
                      customBorder: const CircleBorder(),
                      onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      child: SizedBox(
                        width: 40.spMin,
                        height: 40.spMin,
                        child: Icon(
                          LucideIcons.chevronLeft,
                          size: 22.spMin,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.spMin),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.spMin,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: EdgeInsets.only(left: 8.spMin, top: 4.spMin),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orange uppercase section label (#B84500, letter-spaced).
class FamilyBoardLabel extends StatelessWidget {
  const FamilyBoardLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.spMin),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.sectionLabel,
        ),
      ),
    );
  }
}

/// A white card, 18 px radius, 16 px padding, children spaced by [gap].
class FamilyBoardCard extends StatelessWidget {
  const FamilyBoardCard({
    super.key,
    required this.children,
    this.gap = 10,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.borderColor,
  });

  final List<Widget> children;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  /// Optional left accent or outline colour.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (final (index, child) in children.indexed) {
      if (index > 0) spaced.add(SizedBox(height: gap.spMin));
      spaced.add(child);
    }
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColorLight,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: spaced,
      ),
    );
  }
}

/// The quiet note panel that explains a screen before its controls.
class FamilyBoardNote extends StatelessWidget {
  const FamilyBoardNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.boardNote,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.spMin,
          height: 1.45,
          color: FamilyColors.boardNoteInk,
        ),
      ),
    );
  }
}

/// Secondary grey copy.
class FamilyBoardMuted extends StatelessWidget {
  const FamilyBoardMuted(this.text, {super.key, this.size = 13});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size.spMin,
        height: 1.45,
        color: AppColors.mediumGrey,
      ),
    );
  }
}

/// The 54 px primary button: brand orange, or the family indigo gradient
/// when [indigo] is set.
class FamilyBoardPrimaryButton extends StatelessWidget {
  const FamilyBoardPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.indigo = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool indigo;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final shadow = indigo
        ? FamilyColors.v31HeaderTop.withValues(alpha: 0.3)
        : AppColors.orange.withValues(alpha: 0.25);
    return Opacity(
      opacity: enabled || busy ? 1.0 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: indigo ? null : AppColors.orange,
          gradient: indigo
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FamilyColors.v31HeaderTop, FamilyColors.v31HeaderMid],
                )
              : null,
          borderRadius: BorderRadius.circular(14.spMin),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: SizedBox(
          height: 54.spMin,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.spMin),
              ),
            ),
            onPressed: enabled ? onPressed : null,
            child: busy
                ? SizedBox(
                    width: 20.spMin,
                    height: 20.spMin,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The 48 px full-width outlined secondary button.
class FamilyBoardSecondaryButton extends StatelessWidget {
  const FamilyBoardSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor = AppColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.spMin,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: Colors.white,
          side: const BorderSide(color: FamilyColors.boardOutline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// The 36 px small outlined button (Your photo, Share, Revoke, Remove).
class FamilyBoardSmallButton extends StatelessWidget {
  const FamilyBoardSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor = AppColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.spMin,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 14.spMin),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: AppColors.lightGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.spMin),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// The 44 px text-only button (Close, Stay, Cancel).
class FamilyBoardGhostButton extends StatelessWidget {
  const FamilyBoardGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.spMin,
      child: TextButton(
        style: TextButton.styleFrom(foregroundColor: AppColors.mediumGrey),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// The board's 48 px input: white, 1.5 px grey outline, 14 px radius.
InputDecoration familyBoardInputDecoration(final String hint) {
  OutlineInputBorder outline(final Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.spMin),
    borderSide: BorderSide(color: color, width: 1.5),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 15.spMin,
      fontWeight: FontWeight.w500,
      color: AppColors.mediumGrey,
    ),
    counterText: '',
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 14.spMin,
      vertical: 14.spMin,
    ),
    border: outline(AppColors.lightGrey),
    enabledBorder: outline(AppColors.lightGrey),
    disabledBorder: outline(AppColors.lightGrey),
    focusedBorder: outline(FamilyColors.indigo),
  );
}

/// Text style for board inputs.
TextStyle familyBoardInputStyle() => TextStyle(
  fontSize: 15.spMin,
  fontWeight: FontWeight.w500,
  color: AppColors.ink,
);

/// A labelled switch row: green when on, grey when off.
class FamilyBoardToggleRow extends StatelessWidget {
  const FamilyBoardToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.switchKey,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 15.spMin, color: AppColors.ink),
          ),
        ),
        Switch(
          key: switchKey,
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.green,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: FamilyColors.boardOff,
          trackOutlineColor: const WidgetStatePropertyAll<Color?>(
            Colors.transparent,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A radio card: ink ring and outline when selected.
class FamilyBoardRadioCard extends StatelessWidget {
  const FamilyBoardRadioCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.spMin,
            vertical: 14.spMin,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.lightGrey,
              width: selected ? 2 : 1.5,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.shadowColorLight,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.spMin),
                child: Container(
                  width: 20.spMin,
                  height: 20.spMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.ink : FamilyColors.boardOff,
                      width: selected ? 6.spMin : 2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4.spMin),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.spMin,
                        height: 1.45,
                        color: FamilyColors.boardNoteInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable row: bold title, small grey subtitle, chevron.
class FamilyBoardRow extends StatelessWidget {
  const FamilyBoardRow({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Defaults to a chevron.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.spMin),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 58.spMin),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.spMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 1.spMin),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.spMin,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.spMin),
              trailing ??
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18.spMin,
                    color: AppColors.mediumGrey,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled white group of rows separated by hairlines.
class FamilyBoardGroup extends StatelessWidget {
  const FamilyBoardGroup({super.key, this.title, required this.rows});

  final String? title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final (index, row) in rows.indexed) {
      if (index > 0) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.spMin),
            child: const Divider(height: 1, color: AppColors.shadowColorLight),
          ),
        );
      }
      children.add(row);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          FamilyBoardLabel(title!),
          SizedBox(height: 8.spMin),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.spMin),
            border: Border.all(color: AppColors.shadowColorLight),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

/// A small rounded pill ("Current", "Default").
class FamilyBoardPill extends StatelessWidget {
  const FamilyBoardPill(
    this.text, {
    super.key,
    this.background = FamilyColors.boardIndigoWash,
    this.foreground = FamilyColors.indigo,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.spMin,
      padding: EdgeInsets.symmetric(horizontal: 10.spMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// A 40 px selectable chip: indigo outline and wash when on.
class FamilyBoardChip extends StatelessWidget {
  const FamilyBoardChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 40.spMin,
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FamilyColors.boardIndigoWash : Colors.white,
            borderRadius: BorderRadius.circular(20.spMin),
            border: Border.all(
              color: selected ? FamilyColors.indigo : AppColors.lightGrey,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? FamilyColors.indigo : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a board bottom sheet: white, 24 px top radius, a grab handle,
/// keyboard-safe. [builder] returns the sheet's content blocks, which are
/// spaced 14 px apart like the prototype's sheets.
Future<T?> showFamilyBoardSheet<T>({
  required final BuildContext context,
  required final List<Widget> Function(BuildContext sheetContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) {
      final blocks = builder(sheetContext);
      final spaced = <Widget>[];
      for (final (index, block) in blocks.indexed) {
        if (index > 0) spaced.add(SizedBox(height: 14.spMin));
        spaced.add(block);
      }
      final insets = MediaQuery.viewInsetsOf(sheetContext).bottom;
      final safe = MediaQuery.viewPaddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16.spMin,
          10.spMin,
          16.spMin,
          16.spMin + (insets > safe ? insets : safe),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.spMin,
                  height: 4.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 14.spMin),
              ...spaced,
            ],
          ),
        ),
      );
    },
  );
}

/// The sheet title (22/700) and optional grey subtitle.
class FamilyBoardSheetTitle extends StatelessWidget {
  const FamilyBoardSheetTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.spMin,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.ink,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.spMin),
          FamilyBoardMuted(subtitle!, size: 14),
        ],
      ],
    );
  }
}
