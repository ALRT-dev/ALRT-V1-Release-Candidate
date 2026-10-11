import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/ready/repositories/ready_repository.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

final providerOfReadyRepository = Provider<ReadyRepository>(
  (ref) => ReadyRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
  ),
);
