import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/ready/views/screens/drill_create_screen.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';

class DrillListScreen extends ConsumerStatefulWidget {
  const DrillListScreen({super.key});

  static const route = '/ready/drills';

  @override
  ConsumerState<DrillListScreen> createState() => _DrillListScreenState();
}

class _DrillListScreenState extends ConsumerState<DrillListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final readyState = ref.read(providerOfReady);
      if (!readyState.hasLoadedDrills) {
        ref.read(providerOfReady.notifier).loadDrills();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final readyState = ref.watch(providerOfReady);

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
          'Drills',
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF232326),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.orange,
        onPressed: () => context.push(DrillCreateScreen.route),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: readyState.isLoadingDrills
          ? const Center(child: CircularProgressIndicator())
          : readyState.drills.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(18.spMin),
                  itemCount: readyState.drills.length,
                  separatorBuilder: (_, __) => 10.hSizedBox,
                  itemBuilder: (context, index) =>
                      _buildDrillCard(readyState.drills[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_run_rounded,
              size: 56.spMin,
              color: AppColors.orange.withValues(alpha: 0.4),
            ),
            16.hSizedBox,
            Text(
              'No drills recorded yet',
              style: TextStyle(
                fontSize: 17.spMin,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF232326),
              ),
            ),
            8.hSizedBox,
            Text(
              'Log a drill after you practise your emergency plan with your household.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.spMin,
                color: const Color(0xFF75757E),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillCard(EmergencyDrill drill) {
    final dateStr = DateFormat.yMMMd().format(drill.completedAt);
    final durationStr = drill.durationMinutes != null
        ? '${drill.durationMinutes} min'
        : null;

    return Dismissible(
      key: ValueKey(drill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 18.spMin),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(14.spMin),
        ),
        child: Icon(Icons.delete_rounded, color: Colors.white, size: 22.spMin),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete drill?'),
            content: const Text('This will remove this drill record.'),
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
      },
      onDismissed: (_) {
        ref.read(providerOfReady.notifier).deleteDrill(drill.id);
      },
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: const Color(0xFFE3E1E8)),
        ),
        child: Row(
          children: [
            Container(
              width: 42.spMin,
              height: 42.spMin,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                Icons.directions_run_rounded,
                size: 22.spMin,
                color: AppColors.green,
              ),
            ),
            SizedBox(width: 14.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drill.title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF232326),
                    ),
                  ),
                  SizedBox(height: 3.spMin),
                  Text(
                    [dateStr, if (durationStr != null) durationStr].join(' · '),
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: const Color(0xFF75757E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
