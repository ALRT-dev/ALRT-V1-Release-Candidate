import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/shared/enums/network_connection_status.dart';
import 'package:hazard_app/features/shared/providers/instance_providers.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Provider of [NetworkConnectionCheckerProvider] instance.
final providerOfNetworkConnectionStatus = StateNotifierProvider<
    NetworkConnectionCheckerProvider, NetworkConnectionStatus>(
  (ref) => NetworkConnectionCheckerProvider(
    ref: ref,
    state: NetworkConnectionStatus.connected,
  ),
);

class NetworkConnectionCheckerProvider
    extends StateNotifier<NetworkConnectionStatus> {
  /// 1. Checks if the device is connected to WiFi (or mobile network) or not.
  /// 2. Then, checks if the internet connection is available for that WiFi (or mobile network) or not.
  NetworkConnectionCheckerProvider({
    required final Ref ref,
    required final NetworkConnectionStatus state,
  })  : _ref = ref,
        super(state) {
    _onInit();
  }

  final Ref _ref;

  Connectivity get _connectivity => _ref.read(providerOfConnectivityInstance);
  InternetConnectionChecker get _internetConnectionChecker =>
      _ref.read(providerOfInternetConnectionCheckerInstance);

  /// Listens to the connectivity changes first and then checks if the device is connected to the internet or not.
  void _onInit() {
    if (kIsWeb) return;

    state = NetworkConnectionStatus.connecting;

    final listener = _connectivity.onConnectivityChanged.listen((event) async {
      final isDisconnected = event.contains(ConnectivityResult.none);
      if (isDisconnected) {
        state = NetworkConnectionStatus.disconnected;
      } else {
        state = NetworkConnectionStatus.connecting;
        final isConnected = await _internetConnectionChecker.hasConnection;
        if (isConnected) {
          await Future.delayed(const Duration(seconds: 2));
        }
        state = isConnected
            ? NetworkConnectionStatus.connected
            : NetworkConnectionStatus.disconnected;
      }
    });

    _ref.onDispose(listener.cancel);
  }
}
