import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/providers/states/main_categories_provider_state.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';

final providerOfMainCategories =
    StateNotifierProvider<MainCategoriesProvider, MainCategoriesProviderState>(
      (ref) => MainCategoriesProvider(
        ref: ref,
        initialState: MainCategoriesProviderState(),
      ),
    );

class MainCategoriesProvider
    extends StateNotifier<MainCategoriesProviderState> {
  MainCategoriesProvider({
    required final Ref ref,
    required final MainCategoriesProviderState initialState,
  }) : _ref = ref,
       super(initialState);

  final Ref _ref;
  HazardService get _hazardService => _ref.read(providerOfHazardService);

  /// Fetches the list of main hazard categories from the server.
  Future<void> getAllMainHazardCategories() async {
    state = state.copyWith(
      getMainCategoriesState: const GetMainCategoriesState.loading(),
    );

    final result = await _hazardService.getAllParentHazardCategories();
    if (!mounted) return;

    result.when(
      (categories) {
        state = state.copyWith(
          getMainCategoriesState: GetMainCategoriesState.success(categories),
          mainCategories: categories,
        );
      },
      (error) {
        state = state.copyWith(
          getMainCategoriesState: GetMainCategoriesState.error(error),
        );
      },
    );
  }
}
