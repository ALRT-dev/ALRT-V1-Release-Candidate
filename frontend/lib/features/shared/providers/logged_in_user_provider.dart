import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// A provider that fetches the logged in user details from the [UserService].
final providerOfLoggedInUserFetcher = FutureProvider<Either<AppUser, AppError>>(
  (ref) => ref.watch(providerOfUserService).getCurrentUser(),
);

/// Provides the currently logged in user.
///
/// IMPORTANT: [providerOfLoggedInUserFetcher] should be pre-called before using this provider.
final providerOfLoggedInUser = StateProvider<AppUser?>(
  (ref) => ref.watch(providerOfLoggedInUserFetcher).maybeWhen(
        data: (data) => data.when(
          (user) => user,
          (error) => null,
        ),
        orElse: () => null,
      ),
);
