import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';

part 'main_categories_provider_state.freezed.dart';

@freezed
abstract class MainCategoriesProviderState with _$MainCategoriesProviderState {
  const factory MainCategoriesProviderState({
    /// The list of main hazard categories.
    @Default(<HazardCategory>[]) final List<HazardCategory> mainCategories,

    /// The state of getting main categories.
    @Default(GetMainCategoriesState.initial())
    final GetMainCategoriesState getMainCategoriesState,
  }) = _MainCategoriesProviderState;
}

@freezed
class GetMainCategoriesState with _$GetMainCategoriesState {
  const factory GetMainCategoriesState.initial() =
      _GetMainCategoriesStateInitial;
  const factory GetMainCategoriesState.loading() =
      _GetMainCategoriesStateLoading;
  const factory GetMainCategoriesState.success(
    final List<HazardCategory> categories,
  ) = _GetMainCategoriesStateSuccess;
  const factory GetMainCategoriesState.error(final AppError error) =
      _GetMainCategoriesStateError;
}
