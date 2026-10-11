import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class PlanEditScreen extends ConsumerStatefulWidget {
  const PlanEditScreen({super.key, this.planId});

  final String? planId;

  static const route = '/ready/plans/new';
  static String routeWithId(String id) => '/ready/plans/$id';

  @override
  ConsumerState<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends ConsumerState<PlanEditScreen> {
  final _titleController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _evacuationRouteController = TextEditingController();
  final _notesController = TextEditingController();
  final _newItemController = TextEditingController();
  List<PlanItem> _items = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.planId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final readyState = ref.read(providerOfReady);
        final plan = readyState.plans.where((p) => p.id == widget.planId).firstOrNull;
        if (plan != null) {
          _titleController.text = plan.title;
          _meetingPointController.text = plan.meetingPoint ?? '';
          _evacuationRouteController.text = plan.evacuationRoute ?? '';
          _notesController.text = plan.notes ?? '';
          setState(() {
            _items = plan.items.toList();
          });
        }
      });
    }
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

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(providerOfReady.notifier);

    if (_isEditing) {
      await notifier.updatePlan(
        planId: widget.planId!,
        title: title,
        meetingPoint: _meetingPointController.text.trim(),
        evacuationRoute: _evacuationRouteController.text.trim(),
        notes: _notesController.text.trim(),
        items: _items,
      );
    } else {
      await notifier.createPlan(
        title: title,
        meetingPoint: _meetingPointController.text.trim().isEmpty
            ? null
            : _meetingPointController.text.trim(),
        evacuationRoute: _evacuationRouteController.text.trim().isEmpty
            ? null
            : _evacuationRouteController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        items: _items,
      );
    }
    if (mounted) context.pop();
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(PlanItem(text: text, checked: false));
    });
    _newItemController.clear();
  }

  void _toggleItem(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(checked: !item.checked);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final readyState = ref.watch(providerOfReady);
    final isSaving = readyState.isSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF232326)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Plan' : 'New Plan',
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF232326),
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: AppColors.red, size: 22.spMin),
              onPressed: isSaving
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete plan?'),
                          content: const Text(
                            'This will permanently remove the plan and its items.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text('Delete',
                                  style: TextStyle(color: AppColors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && mounted) {
                        await ref
                            .read(providerOfReady.notifier)
                            .deletePlan(widget.planId!);
                        if (mounted) context.pop();
                      }
                    },
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(18.spMin),
        children: [
          _buildField('Title', _titleController, 'e.g. House Fire Plan'),
          14.hSizedBox,
          _buildField(
            'Meeting Point',
            _meetingPointController,
            'e.g. Front letterbox',
          ),
          14.hSizedBox,
          _buildField(
            'Evacuation Route',
            _evacuationRouteController,
            'e.g. Out the back door, left down the alley',
          ),
          14.hSizedBox,
          _buildField(
            'Notes',
            _notesController,
            'Any other details',
            maxLines: 3,
          ),
          20.hSizedBox,
          Text(
            'CHECKLIST ITEMS',
            style: TextStyle(
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: const Color(0xFFB84500),
            ),
          ),
          10.hSizedBox,
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 6.spMin),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.spMin),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.spMin),
                  leading: GestureDetector(
                    onTap: () => _toggleItem(index),
                    child: Icon(
                      item.checked
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: item.checked ? AppColors.green : const Color(0xFF75757E),
                      size: 22.spMin,
                    ),
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      decoration:
                          item.checked ? TextDecoration.lineThrough : null,
                      color: item.checked
                          ? const Color(0xFF75757E)
                          : const Color(0xFF232326),
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _removeItem(index),
                    child: Icon(Icons.close_rounded,
                        size: 18.spMin, color: const Color(0xFF75757E)),
                  ),
                ),
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  style: TextStyle(fontSize: 14.spMin),
                  decoration: InputDecoration(
                    hintText: 'Add an item',
                    hintStyle: TextStyle(
                      fontSize: 14.spMin,
                      color: const Color(0xFF75757E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.spMin),
                      borderSide: const BorderSide(color: Color(0xFFE3E1E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.spMin),
                      borderSide: const BorderSide(color: Color(0xFFE3E1E8)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.spMin,
                      vertical: 12.spMin,
                    ),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              SizedBox(width: 8.spMin),
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  width: 42.spMin,
                  height: 42.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(10.spMin),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 22.spMin),
                ),
              ),
            ],
          ),
          28.hSizedBox,
          SizedBox(
            width: double.infinity,
            height: 50.spMin,
            child: ElevatedButton(
              onPressed: isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                elevation: 0,
              ),
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
                      _isEditing ? 'Save Changes' : 'Create Plan',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF232326),
          ),
        ),
        SizedBox(height: 6.spMin),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14.spMin),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.spMin,
              color: const Color(0xFF75757E),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.spMin),
              borderSide: const BorderSide(color: Color(0xFFE3E1E8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.spMin),
              borderSide: const BorderSide(color: Color(0xFFE3E1E8)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.spMin,
              vertical: 12.spMin,
            ),
          ),
        ),
      ],
    );
  }
}
