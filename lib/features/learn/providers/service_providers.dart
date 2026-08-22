import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/learn/services/learn_service.dart';

final providerOfLearnService = Provider<LearnService>(
  LearnService.new,
);
