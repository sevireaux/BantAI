import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Watches connectivity and exposes a single stream of "are we online right
/// now" booleans. ReportSyncService listens to this to flush the offline
/// queue the moment a connection comes back — see
/// data/repositories/report_sync_service.dart.
class ConnectivityService {
  ConnectivityService._() {
    _connectivity.onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      _controller.add(online);
    });
  }

  static final instance = ConnectivityService._();
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChange => _controller.stream;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
