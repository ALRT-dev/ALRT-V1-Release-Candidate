import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One choice on step 2: what the household does first.
class _FirstAction {
  const _FirstAction(this.title, this.body);

  final String title;
  final String body;
}

/// The household emergency plan, as the Plan board draws it: a white
/// header "[Kind] plan · step N of 3" over a 4 px progress bar, one
/// question per step, and a white footer with "Save and continue" and
/// "Do this later".
///
/// 1. What the plan is for and where everyone meets.
/// 2. "If a warning is issued near home, then we…": the first action.
/// 3. How you leave, and the things to take.
///
/// Every step saves to the backend plan (POST/PATCH /ready/plans), so
/// "Do this later" keeps what is done so far. The plan has no field for
/// the first action yet, so it is kept as the first line of the notes
/// ("First action: Leave early").
class PlanEditScreen extends ConsumerStatefulWidget {
  const PlanEditScreen({super.key, this.planId});

  final String? planId;

  static const route = '/ready/plans/new';
  static String routeWithId(String id) => '/ready/plans/$id';

  @override
  ConsumerState<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends ConsumerState<PlanEditScreen> {
  static const _page = Color(0xFFF5F5F7);
  static const _ink = Color(0xFF1C1C1E);
  static const _body = Color(0xFF3A3A42);
  static const _muted = Color(0xFF5C5C66);
  static const _line = Color(0xFFE3E6EA);
  static const _track = Color(0xFFECEEF1);
  static const _orange = Color(0xFFE8622A);
  static const _orangeTint = Color(0xFFFFF4EE);
  static const _label = Color(0xFFB84500);
  static const _brand = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF0004)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _kinds = ['Bushfire', 'Flood', 'Storm', 'House fire'];

  static const _actions = [
    _FirstAction('Leave early', 'Pack the car and go to the meeting point'),
    _FirstAction('Check in, then decide', 'Everyone checks in first'),
    _FirstAction('Collect the kids first', 'Pick up from school or care, then go'),
  ];

  static const _firstActionPrefix = 'First action: ';

  final _titleController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _evacuationRouteController = TextEditingController();
  final _notesController = TextEditingController();
  final _newItemController = TextEditingController();
  List<PlanItem> _items = [];

  /// The backend plan this screen is filling in; null until the first
  /// step is saved for a new plan.
  String? _planId;
  int _step = 0;
  String _firstAction = _actions.first.title;

  bool get _isEditing => widget.planId != null;

  @override
  void initState() {
    super.initState();
    _planId = widget.planId;
    _titleController.text = 'Bushfire';
    if (widget.planId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
    }
  }

  void _prefill() {
    final plan = ref
        .read(providerOfReady)
        .plans
        .where((p) => p.id == widget.planId)
        .firstOrNull;
    if (plan == null) return;
    _titleController.text = _kindFromTitle(plan.title);
    _meetingPointController.text = plan.meetingPoint ?? '';
    _evacuationRouteController.text = plan.evacuationRoute ?? '';
    final notes = plan.notes ?? '';
    var rest = notes;
    if (notes.startsWith(_firstActionPrefix)) {
      final end = notes.indexOf('\n');
      final picked = (end < 0 ? notes : notes.substring(0, end))
          .substring(_firstActionPrefix.length)
          .trim();
      if (_actions.any((a) => a.title == picked)) _firstAction = picked;
      rest = end < 0 ? '' : notes.substring(end + 1);
    }
    _notesController.text = rest;
    setState(() => _items = plan.items.toList());
  }

  /// "Bushfire plan" -> "Bushfire"; any other title is kept as written.
  String _kindFromTitle(final String title) =>
      title.endsWith(' plan') ? title.substring(0, title.length - 5) : title;

  String get _kind {
    final t = _titleController.text.trim();
    return t.isEmpty ? 'Emergency' : t;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _meetingPointController.dispose();
    _evacuationRouteController.dispose();
    _notesController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(final TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  String get _notesToSave {
    final rest = _notesController.text.trim();
    return '$_firstActionPrefix$_firstAction${rest.isEmpty ? '' : '\n$rest'}';
  }

  /// Saves everything entered so far. True when the backend accepted it.
  Future<bool> _saveProgress() async {
    final notifier = ref.read(providerOfReady.notifier);
    final title = '$_kind plan';
    final id = _planId;
    if (id == null) {
      await notifier.createPlan(
        title: title,
        meetingPoint: _trimmedOrNull(_meetingPointController),
        evacuationRoute: _trimmedOrNull(_evacuationRouteController),
        notes: _notesToSave,
        items: _items,
      );
    } else {
      await notifier.updatePlan(
        planId: id,
        title: title,
        meetingPoint: _meetingPointController.text.trim(),
        evacuationRoute: _evacuationRouteController.text.trim(),
        notes: _notesToSave,
        items: _items,
      );
    }
    if (!mounted) return false;
    final state = ref.read(providerOfReady);
    if (state.error != null) {
      context.showErrorToast(message: state.error!.message);
      return false;
    }
    if (id == null && state.plans.isNotEmpty) {
      _planId = state.plans.last.id;
    }
    return true;
  }

  Future<void> _onSaveAndContinue() async {
    final ok = await _saveProgress();
    if (!ok || !mounted) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    context.showSuccessToast(message: 'Plan saved');
    context.pop();
  }

  void _onBack() {
    if (_step > 0) {
      setState(() => _step--);
      return;
    }
    context.pop();
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;
    setState(() => _items.add(PlanItem(text: text, checked: false)));
    _newItemController.clear();
  }

  Future<void> _confirmDelete() async {
    final id = _planId;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this plan?'),
        content: const Text('The plan and its checklist are removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(providerOfReady.notifier).deletePlan(id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(providerOfReady.select((s) => s.isSaving));

    return Scaffold(
      backgroundColor: _page,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 20.spMin, 16.spMin, 20.spMin),
              children: switch (_step) {
                0 => _stepWhere(),
                1 => _stepFirstAction(),
                _ => _stepLeave(),
              },
            ),
          ),
          _footer(isSaving),
        ],
      ),
    );
  }

  Widget _header(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            8.spMin,
            MediaQuery.paddingOf(context).top + 8.spMin,
            8.spMin,
            12.spMin,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40.spMin,
                child: IconButton(
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  icon: Icon(LucideIcons.chevronLeft, color: _ink, size: 22.spMin),
                  onPressed: _onBack,
                ),
              ),
              Expanded(
                child: Text(
                  '$_kind plan · step ${_step + 1} of 3',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
              SizedBox(
                width: 40.spMin,
                child: _isEditing || _planId != null
                    ? IconButton(
                        tooltip: 'Delete plan',
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          LucideIcons.trash2,
                          color: _muted,
                          size: 20.spMin,
                        ),
                        onPressed: _confirmDelete,
                      )
                    : null,
              ),
            ],
          ),
        ),
        Container(
          height: 4,
          color: _track,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (_step + 1) / 3,
            child: Container(color: _orange),
          ),
        ),
      ],
    );
  }

  Widget _heading(final String text) => Text(
    text,
    style: TextStyle(
      fontSize: 24.spMin,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.2,
      color: _ink,
    ),
  );

  Widget _intro(final String text) => Padding(
    padding: EdgeInsets.only(top: 16.spMin),
    child: Text(
      text,
      style: TextStyle(fontSize: 14.spMin, height: 1.5, color: _muted),
    ),
  );

  Widget _sectionLabel(final String text) => Padding(
    padding: EdgeInsets.only(top: 16.spMin, bottom: 10.spMin),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: _label,
      ),
    ),
  );

  List<Widget> _stepWhere() {
    return [
      _heading('Where does everyone meet?'),
      _intro(
        'Decide now while you\'re calm. Pick one place everyone knows, '
        'away from the house.',
      ),
      _sectionLabel('This plan is for'),
      Wrap(
        spacing: 8.spMin,
        runSpacing: 8.spMin,
        children: [
          for (final k in _kinds)
            _chip(
              k,
              selected: _titleController.text == k,
              onTap: () => setState(() => _titleController.text = k),
            ),
        ],
      ),
      _sectionLabel('Meeting point'),
      _field(_meetingPointController, 'For example, the front letterbox'),
    ];
  }

  List<Widget> _stepFirstAction() {
    return [
      _heading('If a warning is issued near home, then we…'),
      _intro(
        'Decide now while you\'re calm. Your plan stays in Ready, so it '
        'is one tap away when a warning comes.',
      ),
      _sectionLabel('Pick the first action'),
      for (final a in _actions) ...[
        _radioCard(a),
        SizedBox(height: 10.spMin),
      ],
    ];
  }

  List<Widget> _stepLeave() {
    return [
      _heading('How do we get out, and what do we take?'),
      _intro('Keep it short. Everyone should be able to read it in a minute.'),
      _sectionLabel('Way out'),
      _field(
        _evacuationRouteController,
        'For example, out the back door and left down the lane',
      ),
      _sectionLabel('Take with us'),
      for (var i = 0; i < _items.length; i++) _itemRow(i),
      Row(
        children: [
          Expanded(
            child: _field(
              _newItemController,
              'Add something, for example medicines',
              onSubmitted: (_) => _addItem(),
            ),
          ),
          SizedBox(width: 8.spMin),
          InkWell(
            onTap: _addItem,
            borderRadius: BorderRadius.circular(14.spMin),
            child: Container(
              width: 48.spMin,
              height: 48.spMin,
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(14.spMin),
              ),
              child: Icon(LucideIcons.plus, color: Colors.white, size: 22.spMin),
            ),
          ),
        ],
      ),
      _sectionLabel('Notes'),
      _field(_notesController, 'Anything else everyone should know', maxLines: 3),
    ];
  }

  Widget _chip(
    final String text, {
    required final bool selected,
    required final VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.spMin),
      child: Container(
        height: 40.spMin,
        padding: EdgeInsets.symmetric(horizontal: 16.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _orangeTint : Colors.white,
          borderRadius: BorderRadius.circular(20.spMin),
          border: Border.all(
            color: selected ? _orange : _line,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: _ink,
          ),
        ),
      ),
    );
  }

  Widget _radioCard(final _FirstAction a) {
    final on = _firstAction == a.title;
    return Semantics(
      selected: on,
      button: true,
      child: InkWell(
        onTap: () => setState(() => _firstAction = a.title),
        borderRadius: BorderRadius.circular(14.spMin),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
          decoration: BoxDecoration(
            color: on ? _orangeTint : Colors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(color: on ? _orange : _line, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 18.spMin,
                height: 18.spMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: on ? _orange : const Color(0xFFB8BDC4),
                    width: on ? 5 : 1.5,
                  ),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    Text(
                      a.body,
                      style: TextStyle(fontSize: 13.spMin, color: _muted),
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

  Widget _itemRow(final int index) {
    final item = _items[index];
    return Container(
      margin: EdgeInsets.only(bottom: 8.spMin),
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => setState(
              () => _items[index] = item.copyWith(checked: !item.checked),
            ),
            child: Icon(
              item.checked ? LucideIcons.circleCheck : LucideIcons.circle,
              color: item.checked ? AppColors.green : _muted,
              size: 22.spMin,
            ),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(fontSize: 14.spMin, color: _body),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _items.removeAt(index)),
            child: Icon(LucideIcons.x, size: 18.spMin, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _field(
    final TextEditingController controller,
    final String hint, {
    final int maxLines = 1,
    final ValueChanged<String>? onSubmitted,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.spMin),
      borderSide: const BorderSide(color: _line),
    );
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      style: TextStyle(fontSize: 15.spMin, color: _ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.spMin, color: _muted),
        filled: true,
        fillColor: Colors.white,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 14.spMin,
        ),
      ),
    );
  }

  Widget _footer(final bool isSaving) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.spMin,
        12.spMin,
        16.spMin,
        MediaQuery.paddingOf(context).bottom + 12.spMin,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52.spMin,
            decoration: BoxDecoration(
              gradient: _brand,
              borderRadius: BorderRadius.circular(14.spMin),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0004).withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14.spMin),
                onTap: isSaving ? null : _onSaveAndContinue,
                child: Center(
                  child: isSaving
                      ? SizedBox(
                          width: 22.spMin,
                          height: 22.spMin,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _step < 2 ? 'Save and continue' : 'Save plan',
                          style: TextStyle(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.spMin),
          SizedBox(
            height: 40.spMin,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: _muted),
              onPressed: isSaving ? null : () => context.pop(),
              child: Text(
                'Do this later',
                style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
