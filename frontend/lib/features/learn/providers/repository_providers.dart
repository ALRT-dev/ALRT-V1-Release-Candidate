import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/learn/repositories/learn_repository.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

final providerOfLearnRepository = Provider<LearnRepository>(
  (ref) => LearnRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
  ),
);
