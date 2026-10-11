import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/ready/providers/repository_providers.dart';
import 'package:hazard_app/features/ready/repositories/ready_repository.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ReadyProviderState {
  const ReadyProviderState({
    this.summary,
    this.plans = const [],
    this.drills = const [],
    this.isLoadingSummary = false,
    this.isLoadingPlans = false,
    this.isLoadingDrills = false,
    this.isSaving = false,
    this.error,
    this.hasLoadedPlans = false,
    this.hasLoadedDrills = false,
  });

  final ReadySummary? summary;
  final List<EmergencyPlan> plans;
  final List<EmergencyDrill> drills;
  final bool isLoadingSummary;
  final bool isLoadingPlans;
  final bool isLoadingDrills;
  final bool isSaving;
  final AppError? error;
  final bool hasLoadedPlans;
  final bool hasLoadedDrills;

  ReadyProviderState copyWith({
    ReadySummary? summary,
    List<EmergencyPlan>? plans,
    List<EmergencyDrill>? drills,
    bool? isLoadingSummary,
    bool? isLoadingPlans,
    bool? isLoadingDrills,
    bool? isSaving,
    AppError? error,
    bool clearError = false,
    bool? hasLoadedPlans,
    bool? hasLoadedDrills,
  }) {
    return ReadyProviderState(
      summary: summary ?? this.summary,
      plans: plans ?? this.plans,
      drills: drills ?? this.drills,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isLoadingDrills: isLoadingDrills ?? this.isLoadingDrills,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      hasLoadedPlans: hasLoadedPlans ?? this.hasLoadedPlans,
      hasLoadedDrills: hasLoadedDrills ?? this.hasLoadedDrills,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final providerOfReady =
    StateNotifierProvider.autoDispose<ReadyProvider, ReadyProviderState>(
  (ref) => ReadyProvider(ref: ref),
);

class ReadyProvider extends StateNotifier<ReadyProviderState> {
  ReadyProvider({required Ref ref})
      : _ref = ref,
        super(const ReadyProviderState());

  final Ref _ref;
  ReadyRepository get _repo => _ref.read(providerOfReadyRepository);

  // ---------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------

  Future<void> loadSummary() async {
    state = state.copyWith(isLoadingSummary: true, clearError: true);
    final result = await _repo.getSummary();
    if (!mounted) return;
    result.when(
      (summary) => state = state.copyWith(
        summary: summary,
        isLoadingSummary: false,
      ),
      (error) => state = state.copyWith(
        isLoadingSummary: false,
        error: error,
      ),
    );
  }

  // ---------------------------------------------------------------
  // Plans
  // ---------------------------------------------------------------

  Future<void> loadPlans() async {
    state = state.copyWith(isLoadingPlans: true, clearError: true);
    final result = await _repo.listPlans();
    if (!mounted) return;
    result.when(
      (plans) => state = state.copyWith(
        plans: plans,
        isLoadingPlans: false,
        hasLoadedPlans: true,
      ),
      (error) => state = state.copyWith(
        isLoadingPlans: false,
        error: error,
      ),
    );
  }

  Future<void> createPlan({
    required String title,
    String? meetingPoint,
    String? evacuationRoute,
    String? notes,
    List<PlanItem> items = const [],
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final body = <String, dynamic>{
      'title': title,
      if (meetingPoint != null) 'meetingPoint': meetingPoint,
      if (evacuationRoute != null) 'evacuationRoute': evacuationRoute,
      if (notes != null) 'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
    };
    final result = await _repo.createPlan(body);
    if (!mounted) return;
    result.when(
      (plan) {
        state = state.copyWith(
          plans: [...state.plans, plan],
          isSaving: false,
        );
        // Refresh summary since plan count changed.
        loadSummary();
      },
      (error) => state = state.copyWith(isSaving: false, error: error),
    );
  }

  Future<void> updatePlan({
    required String planId,
    String? title,
    String? meetingPoint,
    String? evacuationRoute,
    String? notes,
    List<PlanItem>? items,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (meetingPoint != null) 'meetingPoint': meetingPoint,
      if (evacuationRoute != null) 'evacuationRoute': evacuationRoute,
      if (notes != null) 'notes': notes,
      if (items != null) 'items': items.map((e) => e.toJson()).toList(),
    };
    final result = await _repo.updatePlan(planId, body);
    if (!mounted) return;
    result.when(
      (updated) {
        final idx = state.plans.indexWhere((p) => p.id == planId);
        final newPlans = [...state.plans];
        if (idx >= 0) {
          newPlans[idx] = updated;
        }
        state = state.copyWith(plans: newPlans, isSaving: false);
      },
      (error) => state = state.copyWith(isSaving: false, error: error),
    );
  }

  Future<void> deletePlan(String planId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _repo.deletePlan(planId);
    if (!mounted) return;
    result.when(
      (_) {
        state = state.copyWith(
          plans: state.plans.where((p) => p.id != planId).toList(),
          isSaving: false,
        );
        loadSummary();
      },
      (error) => state = state.copyWith(isSaving: false, error: error),
    );
  }

  // ---------------------------------------------------------------
  // Drills
  // ---------------------------------------------------------------

  Future<void> loadDrills() async {
    state = state.copyWith(isLoadingDrills: true, clearError: true);
    final result = await _repo.listDrills();
    if (!mounted) return;
    result.when(
      (drills) => state = state.copyWith(
        drills: drills,
        isLoadingDrills: false,
        hasLoadedDrills: true,
      ),
      (error) => state = state.copyWith(
        isLoadingDrills: false,
        error: error,
      ),
    );
  }

  Future<void> createDrill({
    required String title,
    String? planId,
    String? notes,
    required DateTime completedAt,
    int? durationMinutes,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final body = <String, dynamic>{
      'title': title,
      if (planId != null) 'planId': planId,
      if (notes != null) 'notes': notes,
      'completedAt': completedAt.toUtc().toIso8601String(),
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
    };
    final result = await _repo.createDrill(body);
    if (!mounted) return;
    result.when(
      (drill) {
        state = state.copyWith(
          drills: [...state.drills, drill],
          isSaving: false,
        );
        loadSummary();
      },
      (error) => state = state.copyWith(isSaving: false, error: error),
    );
  }

  Future<void> deleteDrill(String drillId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _repo.deleteDrill(drillId);
    if (!mounted) return;
    result.when(
      (_) {
        state = state.copyWith(
          drills: state.drills.where((d) => d.id != drillId).toList(),
          isSaving: false,
        );
        loadSummary();
      },
      (error) => state = state.copyWith(isSaving: false, error: error),
    );
  }
}
