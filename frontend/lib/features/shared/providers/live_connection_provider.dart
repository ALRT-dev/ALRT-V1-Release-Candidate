import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';

/// Whether the live (socket) connection that carries check-ins, check-in
/// requests, SOS and acknowledgments is up right now.
///
/// Screens that show live state watch this so a dropped connection is
/// never silent: the Family header turns its "Live" pill amber and the
/// provider falls back to polling until the socket is back.
final providerOfLiveConnection =
    NotifierProvider<LiveConnectionNotifier, bool>(LiveConnectionNotifier.new);

class LiveConnectionNotifier extends Notifier<bool> {
  @override
  bool build() {
    final socketService = ref.watch(providerOfSocketService);
    final subscription = socketService.onSocketConnectionChanged.listen(
      (connected) => state = connected,
    );
    ref.onDispose(subscription.cancel);
    return socketService.isSocketConnected;
  }
}
