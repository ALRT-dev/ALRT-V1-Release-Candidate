import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/auth/services/auth_service.dart';

final providerOfAuthService = Provider<AuthService>(AuthService.new);
