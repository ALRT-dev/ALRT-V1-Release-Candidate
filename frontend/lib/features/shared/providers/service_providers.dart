import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/services/cache_manager_service.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/services/media_service.dart';
import 'package:hazard_app/features/shared/services/socket_service.dart';
import 'package:hazard_app/features/shared/services/support_service.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';

/// Provides [UserService].
final providerOfUserService = Provider<UserService>(UserService.new);

/// Provides [HazardService].
final providerOfHazardService = Provider<HazardService>(HazardService.new);

/// Provides [SocketService].
final providerOfSocketService = Provider<SocketService>(SocketService.new);

/// Provides [MediaService].
final providerOfMediaService = Provider<MediaService>(MediaService.new);

/// Provider of [CacheManagerService].
final providerOfCacheManagerService = Provider<CacheManagerService>(
  CacheManagerService.new,
);

/// Provides [SupportService].
final providerOfSupportService = Provider<SupportService>(SupportService.new);
