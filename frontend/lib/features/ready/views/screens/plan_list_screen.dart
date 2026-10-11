import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/ready/views/screens/plan_edit_screen.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class PlanListScreen extends ConsumerStatefulWidget {
  const PlanListScreen({super.key});

  static const route = '/ready/plans';

  @override
  ConsumerState<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends ConsumerState<PlanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final readyState = ref.read(providerOfReady);
      if (!readyState.hasLoadedPlans) {
        ref.read(providerOfReady.notifier).loadPlans();
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
          'Emergency Plans',
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
        onPressed: () => context.push(PlanEditScreen.route),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: readyState.isLoadingPlans
          ? const Center(child: CircularProgressIndicator())
          : readyState.plans.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(18.spMin),
                  itemCount: readyState.plans.length,
                  separatorBuilder: (_, __) => 10.hSizedBox,
                  itemBuilder: (context, index) =>
                      _buildPlanCard(readyState.plans[index]),
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
              Icons.description_rounded,
              size: 56.spMin,
              color: AppColors.orange.withValues(alpha: 0.4),
            ),
            16.hSizedBox,
            Text(
              'No emergency plans yet',
              style: TextStyle(
                fontSize: 17.spMin,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF232326),
              ),
            ),
            8.hSizedBox,
            Text(
              'Create a plan so your household knows what to do in an emergency.',
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

  Widget _buildPlanCard(EmergencyPlan plan) {
    final checkedCount = plan.items.where((i) => i.checked).length;
    final totalItems = plan.items.length;

    return GestureDetector(
      onTap: () => context.push(PlanEditScreen.routeWithId(plan.id)),
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: const Color(0xFFE3E1E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF232326),
                    ),
                  ),
                ),
                if (plan.drillCount > 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.spMin,
                      vertical: 2.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.spMin),
                    ),
                    child: Text(
                      '${plan.drillCount} drill${plan.drillCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 10.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 8.spMin),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.spMin,
                  color: const Color(0xFF75757E),
                ),
              ],
            ),
            if (totalItems > 0) ...[
              SizedBox(height: 8.spMin),
              Text(
                '$checkedCount of $totalItems items completed',
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: const Color(0xFF75757E),
                ),
              ),
            ],
            if (plan.meetingPoint != null && plan.meetingPoint!.isNotEmpty) ...[
              SizedBox(height: 6.spMin),
              Row(
                children: [
                  Icon(Icons.place_rounded,
                      size: 14.spMin, color: const Color(0xFF75757E)),
                  SizedBox(width: 4.spMin),
                  Expanded(
                    child: Text(
                      plan.meetingPoint!,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: const Color(0xFF75757E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
