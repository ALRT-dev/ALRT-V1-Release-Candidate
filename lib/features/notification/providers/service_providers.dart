import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/notification/services/notification_service.dart';

final providerOfNotificationService = Provider<NotificationService>(
  NotificationService.new,
);
