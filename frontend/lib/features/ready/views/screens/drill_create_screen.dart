import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';

class DrillCreateScreen extends ConsumerStatefulWidget {
  const DrillCreateScreen({super.key});

  static const route = '/ready/drills/new';

  @override
  ConsumerState<DrillCreateScreen> createState() => _DrillCreateScreenState();
}

class _DrillCreateScreenState extends ConsumerState<DrillCreateScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime _completedAt = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _completedAt = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final durationText = _durationController.text.trim();
    final durationMinutes = durationText.isNotEmpty
        ? int.tryParse(durationText)
        : null;

    final notifier = ref.read(providerOfReady.notifier);
    // Get the plan list so we can optionally link a drill to a plan.
    // For now no plan selector -- can be extended later.
    await notifier.createDrill(
      title: title,
      completedAt: _completedAt,
      durationMinutes: durationMinutes,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(providerOfReady).isSaving;

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
          'Log a Drill',
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF232326),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(18.spMin),
        children: [
          _buildField('Title', _titleController, 'e.g. Fire evacuation drill'),
          14.hSizedBox,
          Text(
            'Date completed',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF232326),
            ),
          ),
          SizedBox(height: 6.spMin),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.spMin,
                vertical: 14.spMin,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.spMin),
                border: Border.all(color: const Color(0xFFE3E1E8)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 18.spMin, color: const Color(0xFF75757E)),
                  SizedBox(width: 8.spMin),
                  Text(
                    DateFormat.yMMMd().format(_completedAt),
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: const Color(0xFF232326),
                    ),
                  ),
                ],
              ),
            ),
          ),
          14.hSizedBox,
          _buildField(
            'Duration (minutes)',
            _durationController,
            'e.g. 15',
            keyboardType: TextInputType.number,
          ),
          14.hSizedBox,
          _buildField('Notes', _notesController, 'How did it go?', maxLines: 3),
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
                      'Log Drill',
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
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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
